find_criterion <- function(row, col, contents) {
  # we iterate backwards through the line until we find the (likely) start of the token
  for (i in (col - 1):0) {
    match <- regexpr("[^a-zA-Z0-9._:]+", substring(contents[row], i, i))
    if (attr(match, "match.length") > 0) {
      return(paste(row, ":", i + 1, sep = ""))
    }
  }
}
