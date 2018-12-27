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
      style = "display:flex; flex-wrap:wrap; padding-top:5px;",
      div(
        style = "background-color:gray;",
        uiOutput(
          outputId = "selectedAwokenSkills"
        )
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
      style = "display:flex; flex-wrap:wrap; padding-top:5px;",
      pickerInput(
        inputId = "pickSuperAS",
        label = "Super Awoken Skills",
        choices = "",
        options = pickerOptions(noneSelectedText = "None"),
        width = "fit"
      ),
      div(
        style = "align-self:center; padding-top:10px;",
        actionButton(
          inputId = "clearSuperAS",
          label = "clear"
        )
      )
    ),
    div(
      style = "display: flex; flex-wrap: wrap; padding-top:10px",
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

  clearSelectedAwokenSkills <- function() {
    selectedAwokenSkills(NULL)

    output$selectedAwokenSkills <- renderUI(
      selectedAwokenSkills()
    )
  }

  updateCheckboxGroupButtons(
    session = session,
    inputId = "selectAwokenSkills",
    choices = getAwokenSkillChoices(AwokenSkill.dt)
  )

  updatePickerInput(
    session = session,
    inputId = "pickSuperAS",
    choices = AwokenSkill.dt$AwokenSkill,
    choicesOpt = list(
      content = sprintf(AwokenSkill.dt$LinkHtml)
    ),
    selected = character(0)
  )

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

    updateCheckboxGroupButtons(
      session = session,
      inputId = "selectAwokenSkills",
      selected = character(0)
    )

  }, ignoreNULL = T, ignoreInit = T
  )

  observeEvent(input$clearSelectedAwokenSkills, {

    clearSelectedAwokenSkills()

  })

  observeEvent(input$clearSuperAS, {

    shinyjs::reset("pickSuperAS")

  })


  observeEvent(input$resetFilters, {

    shinyjs::reset("filters")

    clearSelectedAwokenSkills()

  })


}

shinyApp(ui, server)
