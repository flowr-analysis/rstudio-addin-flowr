#' Installs Node.js locally in the addin's package directory, as well as flowR's NPM package which provides a local version of the flowR shell
#'
#' @export
install_node_addin <- function() {
  base <- node_base_dir()
  print(paste0("Installing Node.js and flowR Shell in ", base))

  node_ver <- read_flowr_pref(pref_node_version, default_node_version)
  assure_valid_semver(node_ver)
  flowr::install_node(node_ver, TRUE, base)

  flowr_ver <- read_flowr_pref(pref_flowr_version, default_flowr_version)
  assure_valid_semver(flowr_ver)
  flowr::install_flowr(flowr_ver, TRUE, base)

  # check if the flowr namespace exists
  if (!system.file(package = "flowr")) {
    stop("Failed to install flowR. Please check the R console for more information.")
  }

  print("Successfully installed Node.js and flowR Shell")
}

node_base_dir <- function() {
  flowr::get_default_node_base_dir("rstudioaddinflowr")
}

assure_valid_semver <- function(version) {
  if (!grepl("^\\d+\\.\\d+\\.\\d+$", version)) {
    stop(paste0("Invalid version: ", version, ". Please specify a valid semver version (e.g. 14.17.0)"))
  }
}