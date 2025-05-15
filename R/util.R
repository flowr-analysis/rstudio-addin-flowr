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
  cat(paste0("[flowR] Highlighting ", length(markers), " tokens for slice ", criterion, "\n"))
}

make_id_to_location_map <- function(analysis) {
  id_to_location_map <- list()
  flowr::visit_node(analysis$results$normalize$ast, function(node) {
    if (!is.null(node$location)) {
      id_to_location_map[paste0(node$info$id)] <<- list(node$location)
    }
  })
  return(id_to_location_map)
}
