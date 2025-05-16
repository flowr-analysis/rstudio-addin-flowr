#' Generates a slice of the currently highlighted variable
#'
#' @export
slice_addin <- function() {
  result <- get_slice()
  mark_slice(result$slice_locations, result$filename, result$criterion)
  return(invisible(result))
}

#' Generates a slice for the currently highlighted variable and displays the corresponding reconstructed code
#'
#' @export
reconstruct_addin <- function() {
  result <- get_slice()$result
  code <- result$results$reconstruct$code
  cat(paste0("[flowR] Showing reconstruct view\n"))
  display_code(if (is.null(code)) "No reconstructed code available" else code)
}

#' Generates a slice for the currently highlighted variable and dumps the corresponding reconstructed code into the R shell
#'
#' @export
dump_reconstruct_addin <- function() {
  result <- get_slice()$result
  code <- result$results$reconstruct$code
  cat(if (is.null(code)) "No reconstructed code available" else code)
  return(invisible(code))
}

get_slice <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  selection <- context$selection[[1]]$range["start"][[1]]

  criterion <- find_criterion(selection[[1]], selection[[2]], context$contents)

  cat(paste0("[flowR] Slicing for criterion ", criterion, "\n"))

  # nolint: object_usage_linter (fails to recognize flowr_session_storage as a global var)
  conn_pid <- flowr_session_storage()
  if (is.null(conn_pid)) {
    return()
  }

  # analyze the file
  analysis <- flowr::send_request(conn_pid$connection, list(
    type = "request-file-analysis",
    id = "0",
    filename = context$path,
    format = "json",
    filetoken = "@tmp",
    content = paste0(context$contents, collapse = "\n")
  ))
  id_to_location_map <- make_id_to_location_map(analysis)

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

  return(list(
    filename = context$path,
    criterion = criterion,
    result = result,
    id_to_location_map = id_to_location_map,
    slice_locations = slice_locations
  ))
}
