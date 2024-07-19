#' @export
install_node_addin <- function() {
  info <- Sys.info()
  os <- switch(info[["sysname"]],
    Windows = "win",
    Darwin = "mac",
    Linux = "linux",
    stop(paste0("Unsupported operating system ", info[["sysname"]]))
  )
  arch <- switch(info[["machine"]],
    "x86-64" = "x64",
    "x86_64" = "x64",
    "x86-32" = "x86",
    "x86_32" = "x86",
    stop(paste0("Unsupported architecture ", info[["machine"]]))
  )
  print(paste0("Running on ", os, arch))

  # TODO node version should be configurable
  node_ver <- "22.5.1"
  # TODO install location? package install directory, RStudio install directory, etc. not here though
  node_base_dir <- path.expand(file.path("~", "_flowrnode"))
  print(paste0("Installing node ", node_ver, " in ", node_base_dir))

  if (dir.exists(node_base_dir)) {
    unlink(node_base_dir, recursive = TRUE)
    print("Removing old node installation")
  }
  dir.create(node_base_dir)

  # url example: https://nodejs.org/dist/v22.5.1/node-v22.5.1-win-x86.zip
  file_type <- switch(os,
    win = "zip",
    linux = "tar.xz",
    mac = "tar.gz"
  )
  node_archive_dest <- file.path(node_base_dir, paste0("node.", file_type))
  node_file_name <- sprintf("node-v%s-%s-%s", node_ver, os, arch)
  download.file(sprintf("https://nodejs.org/dist/v%s/%s.%s", node_ver, node_file_name, file_type), node_archive_dest)
  print(paste0("Downloaded node archive to ", node_archive_dest))

  if (file_type == "zip") {
    unzip(node_archive_dest, exdir = node_base_dir)
  } else {
    untar(node_archive_dest, exdir = node_base_dir)
  }
  unlink(node_archive_dest)

  node_dir <- file.path(node_base_dir, node_file_name)
  print(paste0("Extracted node archive to ", node_dir))

  # TODO install flowr through our local npm
}
