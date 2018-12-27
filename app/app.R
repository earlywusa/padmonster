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

  con <- dbConnect(SQLite(), "db.sqlite3")

  addResourcePath("img", "img")

  AwokenSkill.dt <- setDT(dbReadTable(con, "AwokenSkill"))
  AwokenSkill.dt[, LinkHtml := paste0("<img src=", AwokenSkillIconPath, ">")]

  ActiveSkill.dt <- data.table(ActiveSkillType = c(
    "解绑","解觉醒无效","解锁珠",
    "破防","破大伤吸收","破属性吸收",
    "加combo","延长转珠时间",
    "增伤",
    "单体固伤","全体固伤")
  )

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

  updateCheckboxGroupButtons(
    session = session,
    inputId = "selectAwokenSkills",
    choices = getAwokenSkillChoices(AwokenSkill.dt)
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
        tags$img(src = AwokenSkill.dt[AwokenSkillId == input$selectAwokenSkills, AwokenSkillIconPath])
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

  dbDisconnect(con)

}

shinyApp(ui, server)
