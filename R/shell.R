make_flowr_session_storage <- function() {
  connection <- NULL
  pid <- -1

  # register a shutdown hok that stops the session and disconnects
  setHook(packageEvent("rstudioaddinflowr", "onUnload"), function() {
    if (!is.null(connection)) {
      cat("[flowR] Disconnecting from flowR server\n")
      flowr::disconnect(connection)
    }
    if (pid >= 0) {
      cat(paste0("[flowR] Stopping local flowR server with pid ", pid, "\n"))
      tools::pskill(pid)
    }
  })

  return(function() {
    # connect if we're not connected yet
    if (is.null(connection)) {
      if (read_flowr_pref(pref_use_local_shell, default_use_local_shell)) {
        args <- c("--server", "--port", default_server_port)
        if (!read_flowr_pref(pref_use_docker, default_use_docker)) {
          cat("[flowR] Starting local flowR server with arguments: ", paste(args, collapse = " "), "\n")
          # start the shell using node
          pid <<- tryCatch(
            flowr::exec_flowr(args, TRUE, node_base_dir(), TRUE),
            error = function(e) {
              message(paste0("[flowR] Failed to start local flowR server: ", e, "If flowR is not installed, you can do so by running the \"Install Node.js and flowR Shell\" addin (rstudioaddinflowr:::install_node_addin()). Do you want to to do so right away?"))
              if (rstudioapi::showQuestion("[flowR] Install Node.js and flowR Shell?", "The preferences state that you want to use a local flowR installation, but it is not installed. Do you want to install it now?")) {
                install_node_addin()
              }
              return(-1)
            }
          )
        } else {
          # start the shell using docker
          flowr_ver <- read_flowr_pref(pref_flowr_version, default_flowr_version)
          pid <<- tryCatch(
            flowr::exec_flowr_docker(c("-p", paste0(default_server_port, ":", default_server_port)), flowr_ver, args, TRUE, "docker", TRUE),
            error = function(e) {
              message(paste0("[flowR] Failed to start local flowR server using Docker: ", e, "If you want to run flowR using a local Node.js installation instead, you can change your preferences using the \"Open Preferences\" addin (rstudioaddinflowr:::open_prefs_addin())."))
              return(-1)
            }
          )
        }
        if (pid == -1) {
          return()
        }
        cat(paste0("[flowR] Starting local flowR server with pid ", pid, "\n"))
        # wait until the server has started up
        waited <- 0
        while (waited < 30 && is.na(sys::exec_status(pid, FALSE))) {
          Sys.sleep(1)
          waited <- waited + 1
          cat(paste0("Waiting for flowR server to start up (", waited, "s)\n"))
          if (!is.na(pingr::ping_port(default_server_host, default_server_port, count = 1))) {
            break
          }
        }
        host <- default_server_host
        port <- default_server_port
      } else {
        # connect externally
        cat("[flowR] Connecting to flowR server\n")
        pid <<- -1
        host <- read_flowr_pref(pref_server_host, default_server_host)
        port <- read_flowr_pref(pref_server_port, default_server_port)
      }

      conn_hello <- tryCatch(
        flowr::connect(host, port),
        error = function(e) {
          stop(paste0("[flowR] Failed to connect to flowR server at ", host, ":", port, ": ", e))
        }
      )
      cat(paste0(conn_hello[[2]], "\n"))
      connection <<- conn_hello[[1]]
    } else {
      cat("[flowR] flowR server already connected\n")
    }

    return(list(connection = connection, pid = pid))
  })
}
flowr_session_storage <- make_flowr_session_storage()
