start_or_connect_flowr <- function() {
  if (read_flowr_pref(pref_use_local_shell, default_use_local_shell)) {
    # start the shell
    # TODO display a proper warning when flowR isn't yet installed locally
    pid <- flowr::exec_flowr(c("--server", "--port", default_server_port), TRUE, node_base_dir(), TRUE)
    print(paste0("Starting local flowR server with pid ", pid))
    host <- default_server_host
    port <- default_server_port
  } else {
    # connect externally
    print("Connecting to flowR server")
    pid <- -1
    host <- read_flowr_pref(pref_server_host, default_server_host)
    port <- read_flowr_pref(pref_server_port, default_server_port)
  }

  conn_hello <- flowr::connect(host, port)
  print(conn_hello[[2]])
  return(list(connection = conn_hello[[1]], pid = pid))
}

stop_or_disconnect_flowr <- function(connection, pid) {
  flowr::disconnect(connection)
  if (pid >= 0) {
    print(paste0("Stopping local flowR server with pid ", pid))
    tools::pskill(pid)
  }
}
