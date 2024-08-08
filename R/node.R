#' Installs Node.js locally in the addin's package directory, as well as flowR's NPM package which provides a local version of the flowR shell
#'
#' @export
install_node_addin <- function() {
  base <- node_base_dir()

  node_ver <- read_flowr_pref(pref_node_version, default_node_version)
  flowr::install_node(node_ver, TRUE, base)

  flowr_ver <- read_flowr_pref(pref_flowr_version, default_flowr_version)
  flowr::install_flowr(flowr_ver, TRUE, base)

  print("Successfully installed Node.js and flowR Shell")
}

node_base_dir <- function() {
  flowr::get_default_node_base_dir("rstudioaddinflowr")
}
