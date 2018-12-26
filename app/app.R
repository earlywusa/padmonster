library(data.table)
library(shiny)
library(shinyWidgets)


ui <- fluidPage (

  h2("PAD Monsters"),
  wellPanel(
    h3("Filters"),
    prettyRadioButtons(
      inputId = "selectMainAtt",
      label = "Main Attribute",
      choices = c("Fire", "Water", "Wood", "Light", "Dark", "Any"),
      selected = "Any",
      inline = T
    ),
    prettyRadioButtons(
      inputId = "selectSubAtt",
      label = "Sub Attribute",
      choices = c("Fire", "Water", "Wood", "Light", "Dark", "Null", "Any"),
      selected = "Any",
      inline = T
    ),
    prettyCheckboxGroup(
      inputId = "selectType",
      label = "Type",
      choices = c("God", "Devil", "Dragon", "Balance", "Physical", "Killer", "Healer",
        "Machine", "Evolve", "Enhance", "Awoken", "Vendor"),
      inline = T,
      status = "primary"
    ),
    tags$b("Awoken Skills"),
    div(
      style = "display: flex; flex-wrap: wrap",
      uiOutput(
        outputId = "selectedAwokenSkills"
      ),
      div(
        style = "padding-left:10px",
        actionButton(
          inputId = "clearSelectedAwokenSkills",
          label = "clear"
        )
      )
    ),
    checkboxGroupButtons(
      inputId = "selectAwokenSkills",
      label = "",
      choices = "",
      individual = T
    )
  )

)

server <- function(input, output, session) {

  AwokenSkill.dt <- data.table(
    AwokenSkill = c(
      "Enhance HP",
      "Enhance ATK",
      "Enhance RCV"
    ),
    AwokenSkillIconPath = c(
      "http://www.puzzledragonx.com/en/img/awoken/3.png",
      "http://www.puzzledragonx.com/en/img/awoken/4.png",
      "http://www.puzzledragonx.com/en/img/awoken/5.png"
    )
  )

  AwokenSkill.dt[, LinkHtml := paste0("<img src=", AwokenSkillIconPath, ">")]

  getAwokenSkillChoices <- function(AwokenSkill.dt) {
    choices <- AwokenSkill.dt$AwokenSkill
    names(choices) <- AwokenSkill.dt$LinkHtml
    choices
  }

  initSelectAwokenSkills <- function() {
    updateCheckboxGroupButtons(
      session = session,
      inputId = "selectAwokenSkills",
      choices = getAwokenSkillChoices(AwokenSkill.dt),
      selected = NULL
    )
  }

  initSelectAwokenSkills()

  selectedAwokenSkills <- reactiveVal(NULL)

  observeEvent(input$selectAwokenSkills, {

    selectedAwokenSkills(
      tagList(
        selectedAwokenSkills(),
        tags$img(src = AwokenSkill.dt[AwokenSkill == input$selectAwokenSkills, AwokenSkillIconPath])
      )
    )

    output$selectedAwokenSkills <- renderUI(
      selectedAwokenSkills()
    )

    initSelectAwokenSkills()

  }, ignoreNULL = T, ignoreInit = T
  )

  observeEvent(input$clearSelectedAwokenSkills, {

    selectedAwokenSkills(NULL)

    output$selectedAwokenSkills <- renderUI(
      selectedAwokenSkills()
    )

  })


}

shinyApp(ui, server)
