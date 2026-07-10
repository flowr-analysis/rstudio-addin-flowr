#' Installs a flowR engine so the addin can run flowR locally
#'
#' Downloads and caches a flowR engine via the `flowr` package. By default this
#' is a self-contained binary (no Node.js or Docker required); the engine and
#' version follow the addin preferences.
#'
#' @export
install_node_addin <- function() {
  flowr_ver <- read_flowr_pref(pref_flowr_version, default_flowr_version)
  engine <- read_flowr_pref(pref_engine, default_engine)
  target <- if (engine %in% c("binary", "node")) engine else "binary"
  cat(paste0("[flowR] Installing the flowR ", target, " engine (version ", flowr_ver, ")\n"))
  tryCatch(
    {
      flowr::flowr_install(version = flowr_ver, engine = target)
      cat("[flowR] Successfully installed the flowR engine\n")
    },
    error = function(e) {
      message("[flowR] Failed to install the flowR engine: ", conditionMessage(e))
    }
  )
}
