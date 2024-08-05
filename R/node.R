#' @export
install_node_addin <- function() {
  base <- node_base_dir()

  node_ver <- read_flowr_pref(pref_node_version, default_node_version)
  flowr::install_node(node_ver, TRUE, base)

  flowr_ver <- read_flowr_pref(pref_flowr_version, default_flowr_version)
  flowr::install_flowr(flowr_ver, TRUE, base)
}

node_base_dir <- function() {
  flowr::get_default_node_base_dir("rstudioaddinflowr")
}
