find_criterion <- function(row, col, contents) {
  # we iterate backwards through the line until we find the (likely) start of the token
  for (i in col:0) {
    match <- regexpr("[^a-zA-Z0-9._:]+", substring(contents[row], i - 1, i - 1))
    if (attr(match, "match.length") > 0) {
      return(paste0(row, ":", i))
    }
  }
}

mark_slice <- function(slice_locations, path, criterion) {
  markers <- list()
  for (location in slice_locations) {
    loc <- location[[1]]
    markers[[length(markers) + 1]] <- list(
      type = "info",
      file = path,
      line = as.numeric(loc[[1]]),
      column = as.numeric(loc[[2]]),
      message = paste0("Member of slice for ", criterion, " (", loc[[1]], ":", loc[[2]], " -> ", loc[[3]], ":", loc[[4]], ")")
    )
  }
  rstudioapi::sourceMarkers("flowr-slice", markers)
  print(paste0("Highlighting ", length(markers), " tokens for slice ", criterion))
}

# see https://github.com/rstudio/addinexamples/blob/master/R/utils.R
include_highlightjs <- function() {
  resources <- system.file("www/shared/highlight", package = "shiny")
  code <- "
  Shiny.addCustomMessageHandler('highlight-code', function(m) {
    setTimeout(function() { hljs.highlightBlock(document.querySelector(m['selector'])) }, 100);
  });
  "
  list(
    shiny::includeScript(file.path(resources, "highlight.pack.js")),
    shiny::includeCSS(file.path(resources, "rstudio.css")),
    shiny::tags$script(code)
  )
}

highlight_code <- function(session, selector) {
  session$sendCustomMessage("highlight-code", list(selector = selector))
}
