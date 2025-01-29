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
  cat(paste0("[flowR] Using temp file ", file, "\n"))
  writeLines(html, file)
  getOption("viewer")(file)
}

display_code <- function(code) {
  dark <- rstudioapi::getThemeInfo()[["dark"]]
  theme_key <- if (dark) pref_dark_theme else pref_light_theme
  default_theme <- if (dark) default_dark_theme else default_light_theme
  theme <- read_flowr_pref(theme_key, default_theme)
  display_html(
    sprintf('
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/%s.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>', theme),
    sprintf('
<pre><code style="position: absolute; top: 0; left: 0; bottom: 0; right: 0;" class="language-r">%s</code></pre>
<script>
  hljs.highlightAll();
  <button>Hello World</button>
</script>', code)
  )
}
