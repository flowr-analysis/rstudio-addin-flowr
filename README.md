# rstudio-addin-flowr

RStudio addin for [*flowR*](https://github.com/Code-Inspect/flowr)

## Development

This addin requires the `flowr` package. It's recommended to clone [flowR-R-adapter](https://github.com/flowr-analysis/flowR-R-adapter) into the same parent directory as this addin, and then install a development version of it by running the following:

```R
devtools::install_local("../flowr-R-adapter", force = TRUE)
```

To install a development version of the addin for testing in RStudio, run

```R
devtools::install_local(".", force = TRUE); devtools::reload()
```

from the repository's root directory.
