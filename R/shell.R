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
        # TODO display a proper warning when flowR isn't yet installed locally
        pid <<- flowr::exec_flowr(c("--server", "--port", default_server_port), TRUE, node_base_dir(), TRUE)
        print(paste0("Starting local flowR server with pid ", pid))
        host <- default_server_host
        port <- default_server_port
        # sleep a bit until the server has fully started up
        Sys.sleep(3000)
      } else {
        # connect externally
        print("Connecting to flowR server")
        pid <<- -1
        host <- read_flowr_pref(pref_server_host, default_server_host)
        port <- read_flowr_pref(pref_server_port, default_server_port)
      }

      conn_hello <- flowr::connect(host, port)
      print(conn_hello[[2]])
      connection <<- conn_hello[[1]]
    } else {
      print("flowR server already connected")
    }

    return(list(connection = connection, pid = pid))
  })
}
flowr_session_storage <- make_flowr_session_storage()
