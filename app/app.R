library(data.table)
library(shiny)
library(shinyjs)
library(shinyWidgets)


ui <- fluidPage (
  useShinyjs(),

  h2("PAD Monsters"),
  wellPanel(
    id = "filters",
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
      label = "Types",
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
    ),
    div(
      style = "display: flex; flex-wrap: wrap",
      actionButton(
        inputId = "submitFilters",
        label = "Filter",
        icon = icon("filter"),
        style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"
      ),
      div(
        style = "padding-left: 10px",
        actionButton(
          inputId = "resetFilters",
          label = "Reset"
        )
      )
    )
  )

)

server <- function(input, output, session) {

  addResourcePath("img", "img")

  AwokenSkill.dt <- data.table(
    AwokenSkill = 1:64,
    AwokenSkillIconPath = paste0("img/AwokenSkill/", 1:64, ".png")
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

  clearSelectedAwokenSkills <- function() {
    selectedAwokenSkills(NULL)

    output$selectedAwokenSkills <- renderUI(
      selectedAwokenSkills()
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

    clearSelectedAwokenSkills()

  })


  observeEvent(input$resetFilters, {

    shinyjs::reset("filters")

    clearSelectedAwokenSkills()

  })


}

shinyApp(ui, server)
