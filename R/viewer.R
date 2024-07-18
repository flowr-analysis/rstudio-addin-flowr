display_code <- function(code) {
  html <- sprintf('
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/default.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
  </head>
  <body>
    <div>
      <pre>
        <code class="language-r">
%s
        </code>
      </pre>
    </div>
    <script>
      hljs.highlightAll();
    </script>
  </body>
</html>', code)

  file <- tempfile(fileext = ".html")
  print(paste0("Using temp file ", file))
  writeLines(html, file)
  getOption("viewer")(file)
}
