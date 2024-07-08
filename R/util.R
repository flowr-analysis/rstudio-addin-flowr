find_criterion <- function(row, col, contents) {
  # we iterate backwards through the line until we find the (likely) start of the token
  for (i in col:0) {
    match <- regexpr("[^a-zA-Z0-9._:]+", substring(contents[row], i - 1, i - 1))
    if (attr(match, "match.length") > 0) {
      return(paste(row, ":", i, sep = ""))
    }
  }
}
