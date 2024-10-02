make_flowr_session_storage <- function() {
  connection <- NULL
  pid <- -1

  # register a shutdown hok that stops the session and disconnects
  setHook(packageEvent("rstudioaddinflowr", "onUnload"), function() {
    if (!is.null(connection)) {
      print("Disconnecting from flowR server")
      flowr::disconnect(connection)
    }
    if (pid >= 0) {
      print(paste0("Stopping local flowR server with pid ", pid))
      tools::pskill(pid)
    }
  })

  return(function() {
    # connect if we're not connected yet
    if (is.null(connection)) {
      if (read_flowr_pref(pref_use_local_shell, default_use_local_shell)) {
        # start the shell
        pid <<- tryCatch(
          flowr::exec_flowr(c("--server", "--port", default_server_port), TRUE, node_base_dir(), TRUE),
          error = function(e) {
            message(paste0("Failed to start local flowR server: ", e, "If flowR is not installed, you can do so by running the \"Install Node.js and flowR Shell\" addin (rstudioaddinflowr:::install_node_addin()). Do you want to to do so right away?"))
            if(rstudioapi::showQuestion("Install Node.js and flowR Shell?", "The preferences state that you want to use a local flowR installation, but it is not installed. Do you want to install it now?")) {
              install_node_addin()
            }
          }
        )
        print(paste0("Starting local flowR server with pid ", pid))
        host <- default_server_host
        port <- default_server_port
        # sleep a bit until the server has fully started up
        Sys.sleep(5)
      } else {
        # connect externally
        print("Connecting to flowR server")
        pid <<- -1
        host <- read_flowr_pref(pref_server_host, default_server_host)
        port <- read_flowr_pref(pref_server_port, default_server_port)
      }

      conn_hello <- tryCatch(
        flowr::connect(host, port),
        error = function(e) {
          stop(paste0("Failed to connect to flowR server at ", host, ":", port, ": ", e))
        }
      )
      print(conn_hello[[2]])
      connection <<- conn_hello[[1]]
    } else {
      print("flowR server already connected")
    }

    return(list(connection = connection, pid = pid))
  })
}
flowr_session_storage <- make_flowr_session_storage()
