pref_node_version <- "node_version"
pref_flowr_version <- "flowr_version"
pref_server_host <- "server_host"
pref_server_port <- "server_port"
pref_light_theme <- "light_theme"
pref_dark_theme <- "dark_theme"

default_node_version <- "22.5.1"
default_flowr_version <- "2.0.11"
default_server_host <- "localhost"
default_server_port <- 1042
default_light_theme <- "github"
default_dark_theme <- "github-dark-dimmed"

write_flowr_pref <- function(name, value) {
  rstudioapi::writePreference(paste0("flowr_", name), value)
}

read_flowr_pref <- function(name, default) {
  return(rstudioapi::readPreference(paste0("flowr_", name), default))
}

#' @export
open_prefs_addin <- function() {
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("flowR Preferences"),
    miniUI::miniContentPanel(
      shiny::h4("Local flowR shell"),
      shiny::p("The local node and flowR versions will be used when running flowR commands without being connected to an external flowR server. flowR downloads the specified versions of node and the flowR NPM package if they are not already installed in the package directory."),
      bslib::layout_columns(
        shiny::textInput(pref_node_version, "Local node version", read_flowr_pref(pref_node_version, default_node_version)),
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
