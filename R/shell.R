start_or_connect_flowr <- function() {
  if (read_flowr_pref(pref_use_local_shell, default_use_local_shell)) {
    # start the shell
    # TODO display a proper warning when flowR isn't yet installed locally
    # TODO this is never terminated yet, maybe we should use that sys package or w/e to store a pid and kill it when we're done
    flowr::exec_flowr(paste0("--server --port ", default_server_port), TRUE, node_base_dir(), FALSE)
    print("Starting local flowR shell")
    host <- default_server_host
    port <- default_server_port
  } else {
    # connect externally
    print("Connecting to flowR server")
    host <- read_flowr_pref(pref_server_host, default_server_host)
    port <- read_flowr_pref(pref_server_port, default_server_port)
  }

  conn_hello <- flowr::connect(host, port)
  print(conn_hello[[2]])
  return(conn_hello[[1]])
}
