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
  get_reconstruction(print = TRUE)
}

#' Generates a slice for the given filename and criterion, code fragment and criterion, or the currently highlighted variable in the active RStudio document.
#'
#' @param filename The name of the file to slice. If NULL, the passed code fragment is used.
#' @param code The code fragment to slice, as a character. If also NULL, the currently active document is used.
#' @param criterion The slicing criterion to use. Needs to be non-NULL if filename or code is provided.
#'
#' @return A list containing the filename, criterion, result of the slice request, a mapping from IDs to locations, and the slice locations.
#'
#' @export
get_slice <- function(filename = NULL, code = NULL, criterion = NULL) {
  if (is.null(filename) && is.null(code)) {
    context <- rstudioapi::getActiveDocumentContext()
    filename <- context$path
    code <- paste0(context$contents, collapse = "\n")
    selection <- context$selection[[1]]$range["start"][[1]]
    criterion <- find_criterion(selection[[1]], selection[[2]], context$contents)
    cat(paste0("[flowR] Slicing for criterion ", criterion, "\n"))
  } else if (is.null(criterion)) {
    stop("Slicing for a given filename or code fragment requires passing a slicing criterion")
  } else if (!is.null(filename) && !is.null(code)) {
    stop("Either pass a filename or a code fragment, but not both")
  } else if (!is.null(filename)) {
    code <- paste0(readLines(filename, warn = FALSE), collapse = "\n")
  } else if (!is.null(code)) {
    filename <- "__tmp"
  }

  # nolint: object_usage_linter (fails to recognize flowr_session_storage as a global var)
  conn_pid <- flowr_session_storage()
  if (is.null(conn_pid)) {
    return()
  }

  # analyze the file
  analysis <- flowr::send_request(conn_pid$connection, list(
    type = "request-file-analysis",
    id = "0",
    filename = filename,
    format = "json",
    filetoken = "@tmp",
    content = code
  ))
  id_to_location_map <- flowr::make_id_to_location_map(analysis$results$normalize$ast)

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
    filename = filename,
    criterion = criterion,
    result = result,
    id_to_location_map = id_to_location_map,
    slice_locations = slice_locations
  ))
}

#' Generates a slice for the given filename and criterion, code fragment and criterion, or the currently highlighted variable in the active RStudio document and returns the reconstructed code fragment.
#'
#' @param filename The name of the file to slice. If NULL, the passed code fragment is used.
#' @param code The code fragment to slice, as a character. If also NULL, the currently active document is used.
#' @param criterion The slicing criterion to use. Needs to be non-NULL if filename or code is provided.
#' @param print If TRUE, the reconstructed code is printed to the console and returned invisibly. Defaults to FALSE.
#'
#' @return The reconstructed code fragment for the generated slice.
#'
#' @export
get_reconstruction <- function(filename = NULL, code = NULL, criterion = NULL, print = FALSE) {
  result <- get_slice(filename, code, criterion)$result
  code <- result$results$reconstruct$code
  if (print) {
    cat(if (is.null(code)) "No reconstructed code available" else code)
    return(invisible(code))
  } else {
    return(code)
  }
}
