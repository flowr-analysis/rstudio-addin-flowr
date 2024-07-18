#' @export
slice_addin <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  selection <- context$selection[[1]]$range["start"][[1]]

  criterion <- find_criterion(selection[[1]], selection[[2]], context$contents)

  print(paste0("Slicing for criterion ", criterion))

  # TODO allow configuring host and port
  conn_hello <- flowradapter::connect("localhost", 1042)
  connection <- conn_hello[[1]]
  print(conn_hello[[2]])

  # analyze the file
  analysis <- flowradapter::send_request(connection, list(
    type = "request-file-analysis",
    id = "0",
    filename = context$path,
    format = "json",
    filetoken = "@tmp",
    content = paste0(context$contents, collapse = "\n")
  ))

  # map node ids to their location
  id_to_location_map <- list()
  flowradapter::visit_node(analysis$results$normalize$ast, function(node) {
    if (!is.null(node$location)) {
      id_to_location_map[paste0(node$info$id)] <<- list(node$location)
    }
  })

  # slice the file
  result <- flowradapter::send_request(connection, list(
    type = "request-slice",
    id = "0",
    filetoken = "@tmp",
    criterion = list(criterion)
  ))
  slice <- result$results$slice$result

  # convert slice info to lines
  slice_locations <- list()
  for (id in slice) {
    slice_locations[[length(slice_locations) + 1]] <- id_to_location_map[paste0(id)]
  }
  mark_slice(slice_locations, context$path, criterion)

  # TODO we shouldn't have to disconnect every time! figure out when to auto-disconnect (dispose?)
  flowradapter::disconnect(connection)

  return(result)
}

# TODO this is currently a full "application", so other stuff can't run while the shiny server is open - that's not really intended, but how2fix
#' @export
reconstruct_addin <- function() {
  ui <- miniUI::miniPage(
    include_highlightjs(),
    miniUI::miniContentPanel(
      shiny::uiOutput("code")
    )
  )
  server <- function(input, output, session) {
    result <- slice_addin()
    code <- result$results$reconstruct$code
    print(paste0("Showing reconstruct view for ", code))

    output$code <- shiny::renderUI({
      pre <- shiny::pre(HTML(as.character(tags$code(class = "language-r", code))))
      highlight_code(session, "#code code.language-r")
      return(pre)
    })
  }

  viewer <- shiny::paneViewer(300)
  shiny::runGadget(ui, server, viewer = viewer)
}
