#' @export
sliceAddin <- function() {
  context <- rstudioapi::getActiveDocumentContext()
  selection <- context$selections
  
  # TODO the context needs to turn into the criterion below somehow
  print(context)

  response <- sendFlowrRequest(list(
    type = "request-slice",
    # TODO this id needs to be set to something better?
    id = 0,
    filetoken = "@tmp",
    criterion = list("0:0")
  ))
}

sliceAddin()
