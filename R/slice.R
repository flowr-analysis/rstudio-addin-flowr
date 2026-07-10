#' Generates a slice of the currently highlighted variable
#'
#' @export
slice_addin <- function() {
  result <- get_slice()
  if (is.null(result)) {
    return(invisible(NULL))
  }
  mark_slice(result$slice_locations, result$filename, result$criterion)
  invisible(result)
}

#' Generates a slice for the currently highlighted variable and displays the corresponding reconstructed code
#'
#' @export
reconstruct_addin <- function() {
  result <- get_slice()
  if (is.null(result)) {
    return(invisible(NULL))
  }
  code <- result$result$code
  cat("[flowR] Showing reconstruct view\n")
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
#' @return A list containing the filename, criterion, slice result, a mapping from IDs to locations, and the slice locations.
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
  } else {
    filename <- "__tmp"
  }

  # nolint: object_usage_linter (flowr_session_storage is a package-level global)
  session <- flowr_session_storage()
  if (is.null(session)) {
    return(NULL)
  }

  result <- flowr::slice(code = code, criterion = criterion, session = session)
  # the adapter returns the slice's source locations as a list of length-4
  # numeric vectors, which mark_slice() consumes directly
  slice_locations <- tryCatch(flowr::flowr_slice_locations(result),
                              error = function(e) list())

  list(
    filename = filename,
    criterion = criterion,
    result = result,
    slice_locations = slice_locations
  )
}

#' Generates a slice and returns the reconstructed code fragment.
#'
#' @param filename The name of the file to slice. If NULL, the passed code fragment is used.
#' @param code The code fragment to slice, as a character. If also NULL, the currently active document is used.
#' @param criterion The slicing criterion to use. Needs to be non-NULL if filename or code is provided.
#' @param print If TRUE, the reconstructed code is printed to the console and returned invisibly. Defaults to TRUE.
#'
#' @return The reconstructed code fragment for the generated slice.
#'
#' @export
get_reconstruction <- function(filename = NULL, code = NULL, criterion = NULL, print = TRUE) {
  sliced <- get_slice(filename, code, criterion)
  if (is.null(sliced)) {
    return(invisible(NULL))
  }
  code <- sliced$result$code
  if (print) {
    cat(if (is.null(code)) "No reconstructed code available" else code)
    return(invisible(code))
  }
  code
}

#' Generates a slice and returns the reconstructed code fragment (alias for [get_reconstruction()]).
#'
#' @inheritParams get_reconstruction
#' @return The reconstructed code fragment for the generated slice.
#'
#' @export
slice <- get_reconstruction
