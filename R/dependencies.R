#' Calculates the dependencies of the current file using the dependencies query
#' and dumps the results into the R shell
#'
#' @export
dump_dependencies_addin <- function() {
  print_segment <- function(dependencies, segment, title, name) {
    results <- dependencies$dependencies$results$dependencies[[segment]]
    if (length(results) == 0) {
      return()
    }
    cat(paste0(title, ":\n"))
    for (entry in results) {
      source <- dependencies$id_to_location_map[[entry$nodeId]]
      cat("  ", paste0(entry[[name]], " by ", entry$functionName, " in line ", source[[1]], "\n"))
    }
  }

  dependencies <- get_dependencies()
  print_segment(dependencies, "libraries", "Libraries", "libraryName")
  print_segment(dependencies, "sourcedFiles", "Sourced files", "file")
  print_segment(dependencies, "readData", "Read files", "source")
  print_segment(dependencies, "writtenData", "Written files", "destination")
}

#' Calculates the dependencies of the current file using the dependencies query
#' and displays the results semi-beautifully
#'
#' @export
show_dependencies_addin <- function() {
  add_segment <- function(dependencies, segment, type, name, df) {
    results <- dependencies$dependencies$results$dependencies[[segment]]
    if (length(results) == 0) {
      return()
    }
    for (entry in results) {
      source <- dependencies$id_to_location_map[[entry$nodeId]]
      df <- rbind(df, data.frame(
        Type = type,
        Line = source[[1]],
        Function = entry$functionName,
        Name = entry[[name]]
      ))
    }
    return(df)
  }

  dependencies <- get_dependencies()
  df <- data.frame(matrix(ncol = 3, nrow = 0))
  df <- add_segment(dependencies, "libraries", "Library", "libraryName", df)
  df <- add_segment(dependencies, "sourcedFiles", "Source", "file", df)
  df <- add_segment(dependencies, "readData", "Read", "source", df)
  df <- add_segment(dependencies, "writtenData", "Write", "destination", df)
  View(df, paste0("Dependencies of ", dependencies$file))
}

get_dependencies <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  cat(paste0("[flowR] Getting dependencies for file ", context$path, "\n"))

  # nolint: object_usage_linter (fails to recognize flowr_session_storage as a global var)
  conn_pid <- flowr_session_storage()
  if (is.null(conn_pid)) {
    return()
  }

  analysis <- flowr::send_request(conn_pid$connection, list(
    type = "request-file-analysis",
    id = "0",
    filename = context$path,
    format = "json",
    filetoken = "@tmp",
    content = paste0(context$contents, collapse = "\n")
  ))
  id_to_location_map <- make_id_to_location_map(analysis)

  dependencies <- flowr::send_request(conn_pid$connection, list(
    type = "request-query",
    id = "0",
    filetoken = "@tmp",
    query = list(list(
      type = "dependencies"
    ))
  ))

  return(list(
    dependencies = dependencies,
    id_to_location_map = id_to_location_map,
    file = context$path
  ))
}
