#' runBikrExample
#' 
#' Runs an example shiny app locally to demostrat the functionality of the
#' bikr package

runBikrExample <- function() {
  appDir <- system.file("shiny-examples", "bikrApp", package = "bikr")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `mypackage`.", call. = FALSE)
  }
  
  shiny::runApp(appDir, display.mode = "normal")
}