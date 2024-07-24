#' @export
install_node_addin <- function() {
  os <- get_os()
  arch <- switch(Sys.info()[["machine"]],
    "x86-64" = "x64",
    "x86_64" = "x64",
    "x86-32" = "x86",
    "x86_32" = "x86",
    stop(paste0("Unsupported architecture ", Sys.info()[["machine"]]))
  )

  # TODO node version should be configurable
  node_ver <- "22.5.1"
  node_base_dir <- get_node_base_dir()
  print(paste0("Installing node ", node_ver, " in ", node_base_dir))

  if (dir.exists(node_base_dir)) {
    unlink(node_base_dir, recursive = TRUE)
    print("Removing old node installation")
  }
  dir.create(node_base_dir)

  # url example: https://nodejs.org/dist/v22.5.1/node-v22.5.1-win-x86.zip
  file_type <- if (os == "win") "zip" else "tar.gz"
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

  print(paste0("Extracted node archive to ", file.path(node_base_dir, node_file_name)))

  # TODO flowr version should be configurable
  exec_node_command("npm", "install -g @eagleoutice/flowr")
  exec_flowr("--version")
}

exec_flowr <- function(args) {
  # we installed flowr globally (see above) in the scope of our local node installation, so we can find it here
  flowr_path <- file.path(get_node_exe_dir(), "node_modules", "@eagleoutice", "flowr", "cli", "flowr.js")
  exec_node_command("node", paste(flowr_path, args))
}

exec_node_command <- function(app, args) {
  # linux/mac have binaries in the bin subdirectory, windows has node.exe and npm/npx.cmd in the root, bleh
  path <- if (get_os() == "win") paste0(app, if (app == "node") ".exe" else ".cmd") else file.path("bin", app)
  cmd <- file.path(get_node_exe_dir(), path)
  print(paste0("Executing ", cmd, " ", paste0(args, collapse = " ")))
  system2(cmd, args)
}

get_node_base_dir <- function() {
  # we find the directory to install node into by finding the directory that
  # the currently running instance of the package is (likely) installed in.
  # this may seem like a terrible solution but it's the best one i could come up with :(
  for (path in .libPaths()) {
    for (dir in list.dirs(path, full.names = FALSE, recursive = FALSE)) {
      if (dir == "rstudioaddinflowr") {
        return(file.path(path, dir, "_node"))
      }
    }
  }
  stop(paste0("Could not find rstudioaddinflowr directory in any libPaths"))
}

get_node_exe_dir <- function() {
  base_dir <- get_node_base_dir()
  if (dir.exists(base_dir)) {
    # we installed node like _node/node-versionblahblah/node.exe etc, and since we
    # delete the old installation every time, we expect a single directory of this form
    node_dirs <- list.dirs(base_dir, recursive = FALSE)
    if (length(node_dirs) == 1) {
      return(node_dirs[[1]])
    }
  }
  stop(paste0("Node not installed correctly in ", base_dir))
}

get_os <- function() {
  return(switch(Sys.info()[["sysname"]],
    Windows = "win",
    Linux = "linux",
    Darwin = "darwin",
    stop(paste0("Unsupported operating system ", Sys.info()[["sysname"]]))
  ))
}
