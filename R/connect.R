library(jsonlite)

# TODO this shouldn't be a one-off connection for each command
sendFlowrRequest <- function(command) {
  # TODO make host and port configurable
  connection <- socketConnection(host = "localhost", port = 1042, server = FALSE, open = "r+")
  
  request <- jsonlite::toJSON(command)
  writeLines(request, connection)
  
  response <- readLines(connection, n = 1)
  
  close(connection)
  
  return(response)
}
