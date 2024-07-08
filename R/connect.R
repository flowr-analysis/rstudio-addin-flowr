library(jsonlite)

connection <<- NULL

connect_if_necessary <- function() {
  if (!is.null(connection)) {
    return
  }

  # TODO make host and port configurable
  connection <<- socketConnection(host = "localhost", port = 1042, server = FALSE, blocking = TRUE, open = "r+")

  # the first response is the hello message
  hello <- readLines(connection, n = 1)
  print(hello)
}

send_request <- function(command) {
  if (is.null(connection)) {
    stop("Not connected to server")
  }

  request <- jsonlite::toJSON(command, auto_unbox = TRUE)
  writeLines(request, connection)

  response <- readLines(connection, n = 1)
  return(response)
}

disconnect <- function() {
  if (is.null(connection)) {
    return
  }

  close(connection)
  connection <<- NULL
}
