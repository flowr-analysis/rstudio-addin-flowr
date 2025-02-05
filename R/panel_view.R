#' Open the Flowr Shiny app
#'
#' @export
open_flowr <- function() {
  contents <- rstudioapi::getActiveDocumentContext()
  content <- paste0(contents$contents, collapse = "\n")
  
  
  ui <- miniUI::miniPage(
    miniUI::miniContentPanel(
      shiny::p(content),
    )
    
  )


  # Define server logic ----
  server <- function(input, output) {

  }

  app <- shiny::shinyApp(ui, server)

  subprocess <- callr::r_bg(function(app) {
    shiny::runGadget(app, viewer = shiny::paneViewer(), port = 8092)
  }, args = {
    list(app = app)
  })
  recursive_check <- function(interval = 1L) {
    print("Checking...")
    later::later(recursive_check, interval)
  }
  getOption("viewer")("http://localhost:8092")

  recursive_check()
}
