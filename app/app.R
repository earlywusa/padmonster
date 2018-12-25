library(data.table)
library(shiny)
library(shinyWidgets)


ui <- fluidPage (

  h2("PAD Monsters"),
  wellPanel(
    h3("Filters"),
    prettyRadioButtons(
      inputId = "MainAtt",
      label = "Main Attribute",
      choices = c("Fire", "Water", "Wood", "Light", "Dark", "Any"),
      inline = T
    ),
    prettyRadioButtons(
      inputId = "SubAtt",
      label = "Sub Attribute",
      choices = c("Fire", "Water", "Wood", "Light", "Dark", "Null", "Any"),
      inline = T
    ),
    awesomeCheckboxGroup(
      inputId = "Type",
      label = "Type",
      choices = c("God", "Devil", "Dragon", "Machine", "Physical", "Healer", "Killer"),
      inline = T
    )
  )

)

server <- function(input, output, session) {



}

shinyApp(ui, server)
