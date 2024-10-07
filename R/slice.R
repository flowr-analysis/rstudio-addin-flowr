#' Generates a slice of the currently highlighted variable
#'
#' @export
slice_addin <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  selection <- context$selection[[1]]$range["start"][[1]]

  criterion <- find_criterion(selection[[1]], selection[[2]], context$contents)

  cat(paste0("[flowR] Slicing for criterion ", criterion, "\n"))

  # nolint: object_usage_linter (fails to recognize flowr_session_storage as a global var)
  conn_pid <- flowr_session_storage()

  # analyze the file
  analysis <- flowr::send_request(conn_pid$connection, list(
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
  result <- flowr::send_request(conn_pid$connection, list(
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

  return(invisible(result))
}

#' Generates a slice for the currently highlighted variable and outputs the corresponding reconstructed code
#'
#' @export
reconstruct_addin <- function() {
  result <- slice_addin()
  code <- result$results$reconstruct$code
  cat(paste0("[flowR] Showing reconstruct view"))
  display_code(if(is.null(code)) "No reconstructed code available" else code)
}
