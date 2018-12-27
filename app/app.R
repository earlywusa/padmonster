library(data.table)
library(shiny)
library(shinyjs)
library(shinyWidgets)
library(DBI)
library(RSQLite)


ui <- fluidPage (
  useShinyjs(),

  h2("PAD Monsters"),
  wellPanel(
    id = "filters",

    radioGroupButtons(
      inputId = "selectMainAtt",
      label = "Main Attribute",
      choices = ""
    ),
    radioGroupButtons(
      inputId = "selectSubAtt",
      label = "Sub Attribute",
      choices = ""
    ),
    checkboxGroupButtons(
      inputId = "selectTypes",
      label = "Types",
      choices = ""
    ),

    tags$b("Awoken Skills"),
    div(
      style = "display:flex; flex-wrap:wrap; padding-top:5px;",
      div(
        style = "align-self:center;",
        uiOutput(
          outputId = "selectedAwokenSkills"
        )
      ),
      div(
        style = "padding-left:10px;",
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
        label = "Super Awoken Skill",
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

    prettyCheckboxGroup(
      inputId = "selectActiveSkillTypes",
      label = "Active Skill Types",
      choices = ""
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

  con <- dbConnect(SQLite(), "padmonster.sqlite3")

  addResourcePath("img", "img")


  Attribute.dt <- setDT(dbReadTable(con, "Attribute"))
  Attribute.dt[, LinkHtml := paste0("<img src=", AttributeIconPath, " height='18' width='18'>")]

  AwokenSkill.dt <- setDT(dbReadTable(con, "AwokenSkill"))
  AwokenSkill.dt[, LinkHtml := paste0("<img src=", AwokenSkillIconPath, " height='20' width='20'>")]

  Type.dt <- setDT(dbReadTable(con, "Type"))
  Type.dt[, LinkHtml := paste0("<img src=", TypeIconPath, " height='20' width='20'>")]

  ActiveSkill.dt <- data.table(ActiveSkillType = c(
    "解绑","解觉醒无效","解锁珠",
    "破防","破大伤吸收","破属性吸收",
    "加combo","延长转珠时间",
    "增伤",
    "单体固伤","全体固伤")
  )


  getAttributeChoices <- function(Attribute.dt, sub = F) {
    choices <- c("Any", Attribute.dt$AttributeName)
    names(choices) <- c("Any", Attribute.dt$LinkHtml)
    if (sub) {
      choices <- c(choices, "None")
    }
    choices
  }

  getTypeChoices <- function(Type.dt) {
    choices <- Type.dt$TypeId
    names(choices) <- Type.dt$LinkHtml
    choices
  }

  getAwokenSkillChoices <- function(AwokenSkill.dt) {
    choices <- AwokenSkill.dt$AwokenSkillId
    names(choices) <- AwokenSkill.dt$LinkHtml
    choices
  }

  clearSelectedAwokenSkills <- function() {
    selectedAwokenSkills(NULL)

    output$selectedAwokenSkills <- renderUI(
      selectedAwokenSkills()
    )
  }


  updateRadioGroupButtons(
    session = session,
    inputId = "selectMainAtt",
    choices = getAttributeChoices(Attribute.dt),
  )

  updateRadioGroupButtons(
    session = session,
    inputId = "selectSubAtt",
    choices = getAttributeChoices(Attribute.dt, sub = T)
  )

  updateCheckboxGroupButtons(
    session = session,
    inputId = "selectTypes",
    choices = getTypeChoices(Type.dt)
  )

  updateCheckboxGroupButtons(
    session = session,
    inputId = "selectAwokenSkills",
    choices = getAwokenSkillChoices(AwokenSkill.dt),
    size = "sm"
  )

  updatePickerInput(
    session = session,
    inputId = "pickSuperAS",
    choices = AwokenSkill.dt$AwokenSkillId,
    choicesOpt = list(
      content = sprintf(AwokenSkill.dt$LinkHtml)
    ),
    selected = character(0)
  )

  updatePrettyCheckboxGroup(
    session = session,
    inputId = "selectActiveSkillTypes",
    choices = ActiveSkill.dt$ActiveSkillType,
    inline = T
  )

  selectedAwokenSkills <- reactiveVal(NULL)


  observeEvent(input$selectAwokenSkills, {

    selectedAwokenSkills(
      tagList(
        selectedAwokenSkills(),
        tags$img(
          src = AwokenSkill.dt[AwokenSkillId == input$selectAwokenSkills,
                               AwokenSkillIconPath],
          height = "25",
          width = "25"
        )
      )
    )

    output$selectedAwokenSkills <- renderUI(
      div(
        style = "background-color:gray;",
        selectedAwokenSkills()
      )
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

    updateRadioGroupButtons(
      session = session,
      inputId = "selectMainAtt",
      selected = "Any"
    )

    updateRadioGroupButtons(
      session = session,
      inputId = "selectSubAtt",
      selected = "Any"
    )

    updateCheckboxGroupButtons(
      session = session,
      inputId = "selectTypes",
      selected = character(0)
    )

    clearSelectedAwokenSkills()

  })


  dbDisconnect(con)

}

shinyApp(ui, server)
