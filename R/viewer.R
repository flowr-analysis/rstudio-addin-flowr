display_html <- function(head, body) {
  html <- sprintf('
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    %s
  </head>
  <body>
    %s
  </body>
</html>', head, body)

  file <- tempfile(fileext = ".html")
  print(paste0("Using temp file ", file))
  writeLines(html, file)
  getOption("viewer")(file)
}

display_code <- function(code) {
  dark <- rstudioapi::getThemeInfo()[["dark"]]
  # TODO use the preferences system for this
  style <- if (dark) "github-dark-dimmed" else "github"
  display_html(
    sprintf('
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/%s.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>', style),
    sprintf('
<pre><code style="position: absolute; top: 0; left: 0; bottom: 0; right: 0;" class="language-r">%s</code></pre>
<script>
  hljs.highlightAll();
</script>', code)
  )
}
