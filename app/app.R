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

    # prettyCheckboxGroup(
    #   inputId = "selectActiveSkillTypes",
    #   label = "Active Skill Types",
    #   choices = ""
    # ),

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

  ),

  uiOutput(
    outputId = "monFlt"
  ),

  uiOutput(
    outputId = "monSelData"
  )

)

server <- function(input, output, session) {

  addResourcePath("img", "img")

  con <- dbConnect(SQLite(), "padmonster.sqlite3")

  for (table in dbListTables(con)) {
    assign(paste0(table, ".dt"), setDT(dbReadTable(con, table)))
  }

  Monster.dt[, LinkHtml := paste0("<img src=img/MonsterIcon/", MonsterId, ".png title=", Name, " height='50' width='50'>")]

  Attribute.dt[, LinkHtml := paste0("<img src=img/Attribute/", Id, ".png height='18' width='18'>")]

  AwokenSkill.dt[, LinkHtml := paste0("<img src=img/AwokenSkill/", AwokenSkillId, ".png height='20' width='20'>")]

  Type.dt[, LinkHtml := paste0("<img src=img/Type/", TypeId, ".png height='20' width='20'>")]

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
    selectedAwokenSkills$Id <- NULL

    selectedAwokenSkills$Icon <- NULL

    output$selectedAwokenSkills <- renderUI(
      selectedAwokenSkills$Icon
    )
  }

  getMonsterChoices <- function(Monster.dt) {
    choices <- Monster.dt$MonsterId
    names(choices) <- Monster.dt$LinkHtml
    choices
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
    choices = getTypeChoices(Type.dt),
    checkIcon = list(yes = tags$i(class = "fa fa-check-square",
                                  style = "color: steelblue"),
                                  no = tags$i(class = "fa fa-square-o",
                                  style = "color: steelblue"))
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

  # updatePrettyCheckboxGroup(
  #   session = session,
  #   inputId = "selectActiveSkillTypes",
  #   choices = ActiveSkill.dt$ActiveSkillType,
  #   inline = T
  # )

  selectedAwokenSkills <- reactiveValues(Id = NULL, Icon = NULL)


  observeEvent(input$selectAwokenSkills, {

    selectedAwokenSkills$Id <- c(selectedAwokenSkills$Id, input$selectAwokenSkills)

    selectedAwokenSkills$Icon <-
      tagList(
        selectedAwokenSkills$Icon,
        tags$img(
          src = AwokenSkill.dt[AwokenSkillId == input$selectAwokenSkills,
                               paste0("img/AwokenSkill/", AwokenSkillId, ".png")],
          height = "25",
          width = "25"
        )
      )

    output$selectedAwokenSkills <- renderUI(
      div(
        style = "background-color:gray;",
        selectedAwokenSkills$Icon
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


  awkSklIdCat.dt <- AwokenSkillRelation.dt[order(AwokenSkillId)][
    SuperAwoken == 0,
    paste0(paste0(formatC(AwokenSkillId, width=2, flag="0"), ";"), collapse = ""),
    by = MonsterId]

  temp <- merge(
    AwokenSkillRelation.dt,
    AwokenSkill.dt[, .(AwokenSkillId, LinkHtml)],
    by = "AwokenSkillId"
  )

  awkSklIconCat.dt <- temp[order(MonsterId, Position)][
    SuperAwoken == 0,
    paste0(LinkHtml, collapse = ""),
    by = MonsterId]

  rm(temp)


  monFlt <- reactiveValues(Id = NULL)

  observeEvent(input$submitFilters, {

    if (input$selectMainAtt == "Any") {
      monIdFltByMainAtt <- Monster.dt$MonsterId
    } else {
      monIdFltByMainAtt <- Monster.dt[MainAtt == input$selectMainAtt, MonsterId]
    }

    if (input$selectSubAtt == "Any") {
      monIdFltBySubAtt <- Monster.dt$MonsterId
    } else if (input$selectSubAtt == "None") {
      monIdFltBySubAtt <- Monster.dt[SubAtt == "", MonsterId]
    } else {
      monIdFltBySubAtt <- Monster.dt[SubAtt == input$selectSubAtt, MonsterId]
    }

    if (is.null(selectedAwokenSkills$Id)) {
      monIdFltByAwkSkl <- Monster.dt$MonsterId
    } else {
      awkSklSel <- paste0(
        paste0(formatC(sort(selectedAwokenSkills$Id), width=2, flag="0"), ";"),
        collapse = "")

      monIdFltByAwkSkl <- awkSklIdCat.dt[grepl(awkSklSel, V1), MonsterId]
    }

    monFlt$Id <- Reduce(intersect, list(
      monIdFltByMainAtt,
      monIdFltBySubAtt,
      monIdFltByAwkSkl
    ))

    output$monFlt <- renderUI(
      if (length(monFlt$Id)==0) {
        NULL
      } else {
        radioGroupButtons(
          inputId = "monFlt",
          label = "",
          choices = getMonsterChoices(Monster.dt[MonsterId %in% monFlt$Id]),
          selected = character(0)
        )
      }
    )

  })


  monData.dt <-
    Monster.dt[, .(MonsterId, Name, MainAtt, SubAtt,
      LvMax, Hp, Atk, Rec, Hp110, Atk110, Rec110)]

  monData.dt <- merge(monData.dt, awkSklIconCat.dt, by = "MonsterId", all.x = T)

  monDataLabel.dt <- data.table(label=
    c("ID", "Name", "Main Attribute", "Sub Attribute", "Max Level",
      "HP (Lv.Max)", "ATK (Lv.Max)","RCV (Lv.Max)",
      "HP (Lv.110)", "ATK (Lv.110)","RCV (Lv.110)",
      "Awoken Skills"
      )
  )

  observeEvent(input$monFlt, {
    output$monSelData <- renderTable(
      {
        monSel <- monData.dt[MonsterId == input$monFlt]
        cbind(monDataLabel.dt, transpose(monSel))
      },
      colnames = F,
      bordered = T,
      sanitize.text.function = identity
    )
  })


  dbDisconnect(con)

}

shinyApp(ui, server)
