#' Installs Node.js locally in the addin's package directory, as well as flowR's NPM package which provides a local version of the flowR shell
#'
#' @export
install_node_addin <- function() {
  base <- node_base_dir()
  node_ver <- read_flowr_pref(pref_node_version, default_node_version)
  flowr_ver <- read_flowr_pref(pref_flowr_version, default_flowr_version)
  tryCatch(
    {
      flowr::install_node(node_ver, TRUE, base)
      flowr::install_flowr(flowr_ver, TRUE, base)
      print("Successfully installed Node.js and flowR Shell")
    },
    error = function(e) {
      message(paste0("Failed to install node: ", e, "If you have Docker installed on your system, you can use Docker mode instead."))
      if (rstudioapi::showQuestion("Use Docker mode?", "The local Node.js installation failed. If you have Docker installed on your system, you can enable Docker mode instead. Would you like to do so now?")) {
        write_flowr_pref(pref_use_docker, TRUE)
      }
    }
  )
}

node_base_dir <- function() {
  flowr::get_default_node_base_dir("rstudioaddinflowr")
}
