#' @export
slice_addin <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  selection <- context$selection[[1]]$range["start"][[1]]

  criterion <- find_criterion(selection[[1]], selection[[2]], context$contents)

  print(paste0("Slicing for criterion ", criterion))

  host <- read_flowr_pref(pref_server_host, default_server_host)
  port <- read_flowr_pref(pref_server_port, default_server_port)
  conn_hello <- flowr::connect(host, port)
  connection <- conn_hello[[1]]
  print(conn_hello[[2]])

  # analyze the file
  analysis <- flowr::send_request(connection, list(
    type = "request-file-analysis",
    id = "0",
    filename = context$path,
    format = "json",
    filetoken = "@tmp",
    content = paste0(context$contents, collapse = "\n")
  ))

  # map node ids to their location
  id_to_location_map <- list()
  flowr::visit_node(analysis$results$normalize$ast, function(node) {
    if (!is.null(node$location)) {
      id_to_location_map[paste0(node$info$id)] <<- list(node$location)
    }
  })

  # slice the file
  result <- flowr::send_request(connection, list(
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
  flowr::disconnect(connection)

  return(result)
}

#' @export
reconstruct_addin <- function() {
  result <- slice_addin()
  code <- result$results$reconstruct$code
  print(paste0("Showing reconstruct view for ", code))
  display_code(if (is.null(code)) "No reconstructed code available" else code)
}
