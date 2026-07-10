# Segments of flowr::flowr_overview() shown in the dependency views.
flowr_dep_segments <- list(
  list(key = "library", title = "Libraries", type = "Library"),
  list(key = "source", title = "Sourced files", type = "Source"),
  list(key = "read", title = "Read files", type = "Read"),
  list(key = "write", title = "Written files", type = "Write")
)

#' Dump the current file's dependencies to the R console
#'
#' @export
dump_dependencies_addin <- function() {
  ov <- get_overview()
  if (is.null(ov)) {
    return(invisible(NULL))
  }
  for (seg in flowr_dep_segments) {
    items <- ov[[seg$key]]
    if (length(items) == 0) {
      next
    }
    cat(paste0(seg$title, ":\n"))
    for (it in items) {
      cat("  ", paste0(it$value, " by ", it$functionName, " in line ", it$line, "\n"))
    }
  }
  invisible(ov)
}

#' Show the current file's dependencies in a table
#'
#' @export
show_dependencies_addin <- function() {
  ov <- get_overview()
  if (is.null(ov)) {
    return(invisible(NULL))
  }
  df <- data.frame(Type = character(), Line = character(),
                   Function = character(), Name = character())
  for (seg in flowr_dep_segments) {
    for (it in ov[[seg$key]]) {
      df <- rbind(df, data.frame(Type = seg$type, Line = it$line,
                                 Function = it$functionName, Name = it$value))
    }
  }
  utils::View(df, paste0("Dependencies of ", basename(attr(ov, "file"))))
}

# Overview of the active document (each item has value/functionName/line/criterion).
get_overview <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  cat(paste0("[flowR] Getting dependencies for file ", context$path, "\n"))
  # nolint: object_usage_linter (flowr_session_storage is a package-level global)
  session <- flowr_session_storage()
  if (is.null(session)) {
    return(NULL)
  }
  ov <- flowr::flowr_overview(code = paste0(context$contents, collapse = "\n"),
                              session = session)
  attr(ov, "file") <- context$path
  ov
}
