pref_node_version <- "node_version"
pref_flowr_version <- "flowr_version"
pref_server_host <- "server_host"
pref_server_port <- "server_port"
pref_light_theme <- "light_theme"
pref_dark_theme <- "dark_theme"
pref_use_local_shell <- "use_local_shell"
pref_use_docker <- "use_docker"

default_node_version <- "22.5.1"
default_flowr_version <- "2.2.12"
default_server_host <- "localhost"
default_server_port <- 1042
default_light_theme <- "github"
default_dark_theme <- "github-dark-dimmed"
default_use_local_shell <- TRUE
default_use_docker <- FALSE

write_flowr_pref <- function(name, value) {
  rstudioapi::writePreference(paste0("flowr_", name), value)
}

read_flowr_pref <- function(name, default) {
  return(rstudioapi::readPreference(paste0("flowr_", name), default))
}

#' Opens the Preferences menu, where flowR-specific settings can be changed
#'
#' @export
open_prefs_addin <- function() {
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("flowR Preferences"),
    miniUI::miniContentPanel(
      shiny::h4("Local flowR shell"),
      shiny::p("The local Node.js and flowR versions will be used when running flowR commands without being connected to an external flowR server. flowR downloads the specified versions of Node.js and the flowR NPM package if they are not already installed in the package directory."),
      shiny::p("If you choose to use Docker instead of Node.js to run flowR commands locally, Docker has to be installed on your system, and the Docker daemon has to be running."),
      bslib::layout_columns(
        shiny::checkboxInput(pref_use_local_shell, "Use local shell", read_flowr_pref(pref_use_local_shell, default_use_local_shell)),
        shiny::checkboxInput(pref_use_docker, "Use Docker instead of node", read_flowr_pref(pref_use_docker, default_use_docker)),
      ),
      bslib::layout_columns(
        shiny::textInput(pref_node_version, "Local Node.js version", read_flowr_pref(pref_node_version, default_node_version)),
        shiny::textInput(pref_flowr_version, "Local flowR version", read_flowr_pref(pref_flowr_version, default_flowr_version)),
      ),
      shiny::h4("External flowR connection"),
      shiny::p("Specify which flowR server to connect to when running flowR commands externally. The server must be running and accessible from the local machine."),
      bslib::layout_columns(
        shiny::textInput(pref_server_host, "flowR server host to connect to", read_flowr_pref(pref_server_host, default_server_host)),
        shiny::numericInput(pref_server_port, "flowR server port to connect to", read_flowr_pref(pref_server_port, default_server_port)),
      ),
      shiny::h4("Code previewer"),
      shiny::p("Specify the code highlighting themes to use when displaying reconstructed code in the editor."),
      bslib::layout_columns(
        shiny::textInput(pref_light_theme, "Code previewer light theme", read_flowr_pref(pref_light_theme, default_light_theme)),
        shiny::textInput(pref_dark_theme, "Code previewer dark theme", read_flowr_pref(pref_dark_theme, default_dark_theme)),
      )
    )
  )
  server <- function(input, output, session) {
    shiny::observeEvent(input$done, {
      write_flowr_pref(pref_use_local_shell, input[[pref_use_local_shell]])
      write_flowr_pref(pref_use_docker, input[[pref_use_docker]])
      write_flowr_pref(pref_node_version, input[[pref_node_version]])
      write_flowr_pref(pref_flowr_version, input[[pref_flowr_version]])
      write_flowr_pref(pref_server_host, input[[pref_server_host]])
      write_flowr_pref(pref_server_port, input[[pref_server_port]])
      write_flowr_pref(pref_light_theme, input[[pref_light_theme]])
      write_flowr_pref(pref_dark_theme, input[[pref_dark_theme]])

      shiny::stopApp()
    })
  }

  # 630x650 appears to be the size of the builtin options menus
  viewer <- shiny::dialogViewer("flowR Preferences", width = 630, height = 650)
  shiny::runGadget(ui, server, viewer = viewer)
}
