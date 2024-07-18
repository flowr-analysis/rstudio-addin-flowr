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
  display_html('
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/default.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>', sprintf('
<div>
  <pre>
    <code class="language-r">
%s
    </code>
  </pre>
</div>
<script>
  hljs.highlightAll();
</script>', code))
}
