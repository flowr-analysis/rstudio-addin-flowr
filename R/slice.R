#' @export
slice_addin <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  selection <- context$selection[[1]]$range["start"][[1]]

  criterion <- find_criterion(selection[[1]], selection[[2]], context$contents)

  print(paste("Slicing for criterion ", criterion, sep = ""))

  connect_if_necessary()

  # analyze the file
  send_request(list(
    type = "request-file-analysis",
    id = "0",
    filename = context$path,
    format = "json",
    filetoken = "@tmp",
    content = paste(context$contents, collapse = "\n")
  ))

  # slice the file
  slice <- send_request(list(
    type = "request-slice",
    id = "0",
    filetoken = "@tmp",
    criterion = list(criterion)
  ))
  print(slice)

  # TODO we shouldn't have to disconnect every time! figure out when to auto-disconnect (dispose?)
  disconnect()
}
