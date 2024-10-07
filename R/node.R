#' Installs Node.js locally in the addin's package directory, as well as flowR's NPM package which provides a local version of the flowR shell
#'
#' @export
install_node_addin <- function() {
  base <- node_base_dir()
  cat(paste0("Installing Node.js and flowR Shell in ", base, "\n"))
  node_ver <- read_flowr_pref(pref_node_version, default_node_version)
  assure_valid_semver(node_ver)
  flowr_ver <- read_flowr_pref(pref_flowr_version, default_flowr_version)
  assure_valid_semver(flowr_ver)
  tryCatch(
    {
      flowr::install_node(node_ver, TRUE, base)
      flowr::install_flowr(flowr_ver, TRUE, base)
      # check if the flowr namespace exists
      if ("flowr" %in% rownames(utils::installed.packages())) {
        cat("Successfully installed Node.js and flowR Shell\n")
      } else {
        stop("Failed to install flowR. Please check the R console for more information.\n")
      }
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

assure_valid_semver <- function(version) {
  if (!grepl("^\\d+\\.\\d+\\.\\d+$", version)) {
    stop(paste0("Invalid version: ", version, ". Please specify a valid semver version (e.g. 14.17.0)"))
  }
}
