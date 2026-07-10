pref_engine <- "engine"
pref_flowr_version <- "flowr_version"
pref_light_theme <- "light_theme"
pref_dark_theme <- "dark_theme"

default_engine <- "auto"
default_flowr_version <- "2.11.1"
default_light_theme <- "github"
default_dark_theme <- "github-dark-dimmed"

flowr_engines <- c("auto", "bundled", "binary", "node", "docker")

write_flowr_pref <- function(name, value) {
  rstudioapi::writePreference(paste0("flowr_", name), value)
}

read_flowr_pref <- function(name, default) {
  rstudioapi::readPreference(paste0("flowr_", name), default)
}

#' Opens the Preferences menu, where flowR-specific settings can be changed
#'
#' @export
open_prefs_addin <- function() {
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("flowR Preferences"),
    miniUI::miniContentPanel(
      shiny::h4("flowR engine"),
      shiny::p("How the addin obtains flowR. \"auto\" prefers a cached binary, then the flowR bundle shipped in the package (needs Node.js), then downloads the binary. \"bundled\" runs the shipped flowR on your Node.js. \"binary\" downloads a self-contained flowR executable (no Node.js or Docker needed). \"node\" and \"docker\" run the flowR package or image."),
      bslib::layout_columns(
        shiny::selectInput(pref_engine, "Engine",
          choices = flowr_engines,
          selected = read_flowr_pref(pref_engine, default_engine)),
        shiny::textInput(pref_flowr_version, "flowR version",
          read_flowr_pref(pref_flowr_version, default_flowr_version)),
      ),
      shiny::h4("Code previewer"),
      shiny::p("Highlighting themes used when displaying reconstructed code."),
      bslib::layout_columns(
        shiny::textInput(pref_light_theme, "Light theme",
          read_flowr_pref(pref_light_theme, default_light_theme)),
        shiny::textInput(pref_dark_theme, "Dark theme",
          read_flowr_pref(pref_dark_theme, default_dark_theme)),
      )
    )
  )
  server <- function(input, output, session) {
    shiny::observeEvent(input$done, {
      write_flowr_pref(pref_engine, input[[pref_engine]])
      write_flowr_pref(pref_flowr_version, input[[pref_flowr_version]])
      write_flowr_pref(pref_light_theme, input[[pref_light_theme]])
      write_flowr_pref(pref_dark_theme, input[[pref_dark_theme]])
      shiny::stopApp()
    })
  }

  viewer <- shiny::dialogViewer("flowR Preferences", width = 630, height = 650)
  shiny::runGadget(ui, server, viewer = viewer)
}
