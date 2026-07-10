# Turning a cursor position into a slicing criterion is engine-agnostic and
# lives in the adapter; this only adapts the editor's (row, col, contents).
find_criterion <- function(row, col, contents) {
  flowr::flowr_criterion_at(row, col, contents)
}

# Render slice locations (as returned by flowr::flowr_slice_locations()) as
# RStudio gutter markers.
mark_slice <- function(slice_locations, path, criterion) {
  markers <- lapply(slice_locations, function(loc) {
    list(
      type = "info",
      file = path,
      line = as.numeric(loc[[1]]),
      column = as.numeric(loc[[2]]),
      message = paste0("Member of slice for ", criterion, " (",
                       loc[[1]], ":", loc[[2]], " -> ", loc[[3]], ":", loc[[4]], ")")
    )
  })
  rstudioapi::sourceMarkers("flowr-slice", markers)
  cat(paste0("[flowR] Highlighting ", length(markers), " tokens for slice ", criterion, "\n"))
}
