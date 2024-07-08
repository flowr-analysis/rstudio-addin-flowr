#' @export
sliceAddin <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  selection <- context$selection[[1]]$range["start"][[1]]

  # TODO this only works if the cursor is placed at the start of the variable right now!
  criterion <- paste(selection[[1]], ":", selection[[2]], sep = "")

  print(paste("Slicing for criterion ", criterion, sep = ""))

  connectIfNecessary()

  # analyze the file
  analysis <- sendRequest(list(
    type = "request-file-analysis",
    id = "0",
    filename = context$path,
    format = "json",
    filetoken = "@tmp",
    content = paste(context$contents, collapse = "\n")
  ))

  # slice the file
  slice <- sendRequest(list(
    type = "request-slice",
    id = "0",
    filetoken = "@tmp",
    criterion = list(criterion)
  ))
  print(slice)

  disconnect()
}
