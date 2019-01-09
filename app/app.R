library(data.table)
library(shiny)
library(shinythemes)
library(shinyWidgets)
library(DBI)
library(RSQLite)


ui <- fluidPage (
  theme = shinytheme("slate"),

  tags$head(
    tags$style(HTML("
      .radiobtn {
        padding-left: 10px; padding-right: 10px;
        padding-top: 5px; padding-bottom: 5px;
      }

      .checkbtn {
        padding: 5px;
      }

      .control-label {
        margin-bottom: -5px;
      }

      table {
        border-collapse: collapse;
      }

      td, th {
        border: 1px solid rgb(0,0,0);
        text-align: center;
        padding: 3px;
      }

      table tr:first-child td {
        border-top: 0;
      }
      table tr td:first-child {
        border-left: 0;
      }
      table tr:last-child td {
        border-bottom: 0;
      }
      table tr td:last-child {
        border-right: 0;
      }

      .state {
        width: 85px;
        font-size: 10px;
      }

      #monsterId {
        font-size: 16px;
        padding: 16px;
      }

    "))
  ),

  tags$script(
    'Shiny.addCustomMessageHandler(
      "scrolltoid",
      function(e_id) {
        document.getElementById(e_id).scrollIntoView();
      }
    );'
  ),

  tags$script("
    var socket_timeout_interval
    var n = 0
    $(document).on('shiny:connected', function(event) {
      socket_timeout_interval = setInterval(function() {
        Shiny.onInputChange('count', n++)
      }, 15000)
    });
    $(document).on('shiny:disconnected', function(event) {
      clearInterval(socket_timeout_interval)
    });
  "),

  tags$style(".swal-modal {width: 300px;}"),

  titlePanel("PAD Monsters"),

  wellPanel(

    tabsetPanel(

      tabPanel(
        title = "Search by Filtering",

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
          style = "display:flex; flex-wrap:wrap;",
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
              label = "Clear"
            )
          ),
          div(
            style = "padding-left:10px; padding-top:7px;",
            materialSwitch(
              inputId = "toggleIncludeSuperAwoken",
              label = tags$b("Inc. Super"),
              value = T,
              status = "info"
            )
          ),
          div(
            style = "padding-left:10px;",
            actionButton(
              inputId = "toggleAwokenSkillList",
              label = "Hide/Show List"
            )
          )
        ),
        conditionalPanel(
          condition = "input.toggleAwokenSkillList%2==0",
          div(
            style = "margin-top:-15px; margin-bottom:-5px; margin-left:-8px; margin-right:-25px;",
            checkboxGroupButtons(
              inputId = "selectAwokenSkills",
              label = "",
              choices = "",
              individual = T
            )
          )
        ),

        # div(
        #   style = "display:flex; flex-wrap:wrap; padding-top:5px;",
        #   pickerInput(
        #     inputId = "pickSuperAS",
        #     label = "Super Awoken Skill",
        #     choices = "",
        #     options = pickerOptions(noneSelectedText = "None"),
        #     width = "fit"
        #   )
        # ),

        div(
          style = "display:flex; flex-wrap:wrap; align-items:center;",
          tags$b("Active Skill Type"),
          div(
            style = "padding-left:10px;",
            actionButton(
                inputId = "toggleActiveSkillTypeList",
                label = "Hide/Show List"
            )
          )
        ),
        conditionalPanel(
          condition = "input.toggleActiveSkillTypeList%2==1",
          div(
            style = "display:flex; flex-wrap:wrap; margin-top:-5px;",
            prettyCheckboxGroup(
              inputId = "selectActiveSkillTypes",
              label = "",
              choices = ""
            )
          )
        ),

        div(
          style = "display: flex; flex-wrap: wrap; padding-top:10px",
          div(
            actionButton(
              inputId = "submitFilters",
              label = "Filter",
              icon = icon("filter"),
              style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"
            )
          ),
          div(
            style = "padding-left:10px;",
            actionButton(
              inputId = "resetFilters",
              label = "Reset"
            )
          )
        ),

        div(
          style = "display: flex; flex-wrap: wrap; padding-top:10px",
          div(
            pickerInput(
              inputId = "ordering",
              label = "Sort Results by",
              choices = c("ID" = "MonsterId",
                "HP (LvMax)" = "Hp", "ATK (LvMax)" = "Atk", "RCV (LvMax)" = "Rec", "Weighted (LvMax)" = "Weighted",
                "HP (inc. Lv110)" = "HpAll", "ATK (inc. Lv110)" = "AtkAll", "RCV (inc. Lv110)" = "RecAll", "Weighted (inc. Lv110)" = "WeightedAll")
            )
          ),
          div(
            style = "padding-left:10px;",
            pickerInput(
              inputId = "showTopN",
              label = "Show Results",
              choices = c("Top 10" = 10, "Top 50" = 50, "Top 100" = 100, "All" = 10000),
              selected = 50
            )
          )
        )

      ), # tabPanel

      tabPanel(
        title = "Search by ID",

        textInput(
          inputId = "monsterId",
          label = "",
          placeholder = "Input Monster ID (e.g. 4428)",
          width = 300
        ),

        actionButton(
          inputId = "submitMonsterId",
          label = "Search",
          icon = icon("search"),
          style = "color: #fff; background-color: #337ab7; border-color: #2e6da4"
        )
      )

    ) # tabsetPanel

  ), # wellPanel

  div(
      style = "margin-top:-30px; margin-right:-10px; display:flex; justify-content: center;",
    uiOutput(
      outputId = "monsterFiltered"
    )
  ),

  uiOutput(
    outputId = "monsterDataViewer"
  )

)

server <- function(input, output, session) {

  addResourcePath("img", "img")

  con <- dbConnect(SQLite(), "padmonster.sqlite3")

  for (table in dbListTables(con)) {
    assign(paste0(table, ".dt"), setDT(dbReadTable(con, table)))
  }

  Monster.dt[, LinkHtml := paste0("<img src=img/MonsterIcon/", MonsterId, ".png title=", Name, " height='47' width='47'>")]

  Monster.dt[, Weighted := Hp/10 + Atk/5 + Rec/3]
  Monster.dt[, Weighted110 := Hp110/10 + Atk110/5 + Rec110/3]

  Monster.dt[, HpAll := pmax(Hp, Hp110, na.rm = T)]
  Monster.dt[, AtkAll := pmax(Atk, Atk110, na.rm = T)]
  Monster.dt[, RecAll := pmax(Rec, Rec110, na.rm = T)]
  Monster.dt[, WeightedAll := pmax(Weighted, Weighted110, na.rm = T)]

  Attribute.dt[, LinkHtml := paste0("<img src=img/Attribute/", Id, ".png height='18' width='18'>")]

  AwokenSkill.dt[, LinkHtml := paste0("<img src=img/AwokenSkill/", AwokenSkillId, ".png height='20' width='20'>")]

  Type.dt[, LinkHtml := paste0("<img src=img/Type/", TypeId, ".png height='20' width='20'>")]
  Type.dt[, LinkHtmlL := paste0("<img src=img/Type/", TypeId, ".png height='23' width='23'>")]

  ActiveSkill.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "火珠", replacement = "<img src=img/Orb/Fire.png  height='19' width='19'>")]
  ActiveSkill.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "水珠", replacement = "<img src=img/Orb/Water.png  height='19' width='19'>")]
  ActiveSkill.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "木珠", replacement = "<img src=img/Orb/Wood.png  height='19' width='19'>")]
  ActiveSkill.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "光珠", replacement = "<img src=img/Orb/Light.png  height='19' width='19'>")]
  ActiveSkill.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "暗珠", replacement = "<img src=img/Orb/Dark.png  height='19' width='19'>")]
  ActiveSkill.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "心珠", replacement = "<img src=img/Orb/Heart.png  height='19' width='19'>")]
  ActiveSkill.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "毒珠", replacement = "<img src=img/Orb/Poison.png  height='19' width='19'>")]
  ActiveSkill.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "火\\+珠", replacement = "<img src=img/Orb/Fire+.png  height='19' width='19'>")]
  ActiveSkill.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "水\\+珠", replacement = "<img src=img/Orb/Water+.png  height='19' width='19'>")]
  ActiveSkill.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "木\\+珠", replacement = "<img src=img/Orb/Wood+.png  height='19' width='19'>")]
  ActiveSkill.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "光\\+珠", replacement = "<img src=img/Orb/Light+.png  height='19' width='19'>")]
  ActiveSkill.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "暗\\+珠", replacement = "<img src=img/Orb/Dark+.png  height='19' width='19'>")]
  ActiveSkill.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "心\\+珠", replacement = "<img src=img/Orb/Heart+.png  height='19' width='19'>")]
  ActiveSkill.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "毒\\+珠", replacement = "<img src=img/Orb/Poison+.png  height='19' width='19'>")]
  ActiveSkill.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "死珠", replacement = "<img src=img/Orb/Dead.png  height='19' width='19'>")]
  ActiveSkill.dt[, ActiveSkillDescription := gsub(x = ActiveSkillDescription,
    pattern = "炸彈珠", replacement = "<img src=img/Orb/Bomb.png  height='19' width='19'>")]

  ActiveSkillType.dt[ActiveSkillType=="傷害吸收無效化", ActiveSkillType := "大傷吸收無效"]
  ActiveSkillType.dt[, ActiveSkillType := sub("傷害增幅", "增加傷害", ActiveSkillType)]
  ActiveSkillType.dt[ActiveSkillType=="全場攻擊", ActiveSkillType := "全體攻擊"]
  ActiveSkillType.dt[ActiveSkillType=="冷卻時間縮短", ActiveSkillType := "縮短冷卻時間"]
  ActiveSkillType.dt[ActiveSkillType%in%c("受到傷害減少","受到傷害無效化"), ActiveSkillType := "減少受到的傷害"]
  ActiveSkillType.dt[ActiveSkillType=="回復提升", ActiveSkillType := "提升回復"]
  ActiveSkillType.dt[ActiveSkillType=="增加移動時間", ActiveSkillType := "增加轉珠時間"]
  ActiveSkillType.dt[ActiveSkillType=="減少移動時間", ActiveSkillType := "減少轉珠時間"]
  ActiveSkillType.dt[grepl(x = ActiveSkillType, pattern = "大炮（全體"), ActiveSkillType := "大炮（全體）"]
  ActiveSkillType.dt[grepl(x = ActiveSkillType, pattern = "大炮（單體"), ActiveSkillType := "大炮（單體）"]
  ActiveSkillType.dt[ActiveSkillType=="天降的寶珠不會產生COMBO", ActiveSkillType := "無天降"]
  ActiveSkillType.dt[ActiveSkillType=="寶珠刷新", ActiveSkillType := "刷新寶珠"]
  ActiveSkillType.dt[ActiveSkillType=="寶珠強化", ActiveSkillType := "強化寶珠"]
  ActiveSkillType.dt[ActiveSkillType=="寶珠轉換", ActiveSkillType := "轉換寶珠"]
  ActiveSkillType.dt[ActiveSkillType=="寶珠鎖定", ActiveSkillType := "鎖定寶珠"]
  ActiveSkillType.dt[ActiveSkillType=="屬性傷害吸收無效化", ActiveSkillType := "屬性傷害吸收無效"]
  ActiveSkillType.dt[ActiveSkillType=="攻擊延遲", ActiveSkillType := "延遲"]
  ActiveSkillType.dt[ActiveSkillType=="自身屬性變換", ActiveSkillType := "轉換自身屬性"]
  ActiveSkillType.dt[ActiveSkillType=="解除鎖定", ActiveSkillType := "解除寶珠鎖定"]
  ActiveSkillType.dt[ActiveSkillType=="防禦力下降", ActiveSkillType := "減少敵人防禦"]
  ActiveSkillType.dt[ActiveSkillType=="隊長轉換", ActiveSkillType := "轉換隊長"]
  ActiveSkillType.dt[ActiveSkillType=="COMBO增加", ActiveSkillType := "增加Combo"]
  ActiveSkillType.dt[ActiveSkillType=="HP吸取", ActiveSkillType := "吸收HP"]
  ActiveSkillType.dt[ActiveSkillType=="HP回復", ActiveSkillType := "回復HP"]
  ActiveSkillType.dt[ActiveSkillType=="增加傷害（類型）", ActiveSkillType := "增傷（Type）"]
  ActiveSkillType.dt[ActiveSkillType=="增加傷害（屬性）", ActiveSkillType := "增傷（屬性）"]
  ActiveSkillType.dt[ActiveSkillType=="增加傷害（全隊）", ActiveSkillType := "增傷（按覺醒數量）"]


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

  # allSuperASId <- AwokenSkillRelation.dt[SuperAwoken==1, sort(unique(AwokenSkillId))]

  # updatePickerInput(
  #   session = session,
  #   inputId = "pickSuperAS",
  #   choices = c("Any", allSuperASId),
  #   choicesOpt = list(
  #     content = sprintf(c("Any", AwokenSkill.dt[AwokenSkillId %in% allSuperASId, LinkHtml]))
  #   ),
  #   selected = "Any"
  # )

  allActiveSkillTypes <- ActiveSkillType.dt[, sort(unique(ActiveSkillType))]
  # sortByStringLength <- function(v) v[order(nchar(v))]

  updatePrettyCheckboxGroup(
    session = session,
    inputId = "selectActiveSkillTypes",
    choices = allActiveSkillTypes,
    inline = T
  )

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


  observeEvent(input$resetFilters, {

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

    # updatePickerInput(
    #   session = session,
    #   inputId = "pickSuperAS",
    #   selected = "Any"
    # )

  })


  monFlt <- reactiveValues(Id = NULL)

  forAutoScroll <- reactiveValues(V1 = 0)

  observeEvent(input$submitFilters, {

    forAutoScroll$V1 <- 0

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

    if (length(input$selectTypes)==0) {
      monIdFltByType <- Monster.dt$MonsterId
    } else {
      monIdFltByType <- TypeRelation.dt[TypeId %in% input$selectTypes, unique(MonsterId)]
    }

    if (is.null(selectedAwokenSkills$Id)) {
      monIdFltByAwkSkl <- monIdFltByAwkSklIncOneSup <- Monster.dt$MonsterId
    } else {
      monIdFltByAwkSkl.ls <- lapply(
        unique(selectedAwokenSkills$Id),
        function(x) AwokenSkillRelation.dt[SuperAwoken == 0, sum(AwokenSkillId==x)>=sum(selectedAwokenSkills$Id==x), by = MonsterId][V1==TRUE, MonsterId]
      )

      monIdFltByAwkSkl <- Reduce(intersect, monIdFltByAwkSkl.ls)

      monIdFltByAllAwkSkl.ls <- lapply(
        unique(selectedAwokenSkills$Id),
        function(x) AwokenSkillRelation.dt[, sum(AwokenSkillId==x)>=sum(selectedAwokenSkills$Id==x), by = MonsterId][V1==TRUE, MonsterId]
      )

      monIdFltByAllAwkSkl <- Reduce(intersect, monIdFltByAllAwkSkl.ls)

      monIdDiffBySupAwkSkl.vt <- as.vector(unlist(mapply(setdiff, monIdFltByAllAwkSkl.ls, monIdFltByAwkSkl.ls)))
      monIdDiffByMoreThanOneSupAwkSkl <- data.table(V1 = monIdDiffBySupAwkSkl.vt)[, .N, by = V1][N>1, V1]

      monIdFltByAwkSklIncOneSup <- setdiff(monIdFltByAllAwkSkl, monIdDiffByMoreThanOneSupAwkSkl)
    }

    # if (input$pickSuperAS == "Any") {
    #   monIdFltBySuperAS <- Monster.dt$MonsterId
    # } else {
    #   monIdFltBySuperAS <- AwokenSkillRelation.dt[SuperAwoken == 1 & AwokenSkillId == input$pickSuperAS, MonsterId]
    # }

    if (length(input$selectActiveSkillTypes)==0) {
      monIdFltByASType <- Monster.dt$MonsterId
    } else {
      ASIdFltByASType <- ActiveSkillType.dt[, all(input$selectActiveSkillTypes %in% ActiveSkillType), by = ActiveSkillId][V1==T, ActiveSkillId]
      monIdFltByASType <- Monster.dt[ActiveSkillId %in% ASIdFltByASType, MonsterId]
    }

    monFlt$Id <- Reduce(intersect, list(
      monIdFltByMainAtt,
      monIdFltBySubAtt,
      if (input$toggleIncludeSuperAwoken==T) {
        monIdFltByAwkSklIncOneSup
      } else {
        monIdFltByAwkSkl
      },
      # monIdFltBySuperAS,
      monIdFltByType,
      monIdFltByASType
    ))

    session$sendCustomMessage(type = "scrolltoid", message = list("monsterFiltered"))

  })

  observeEvent(input$submitMonsterId, {
    if (!as.integer(input$monsterId) %in% Monster.dt$MonsterId) {
      sendSweetAlert(session = session, text = "Monster ID does not exist", title = "")
    } else {
      monFlt$Id <- as.integer(input$monsterId)
    }
  })

  output$monsterFiltered <- renderUI(
    if (length(monFlt$Id)==0) {
      NULL
    } else {
      tagList(
        tags$head(
          tags$style(HTML("
            .btn-monster.btn {
              padding:0px;
            }
          "))
        ),
        radioGroupButtons(
          inputId = "selectMonster",
          label = "",
          choices = getMonsterChoices(
            Monster.dt[MonsterId %in% monFlt$Id][order(-get(input$ordering))][1:min(length(monFlt$Id), as.integer(input$showTopN))]
          ),
          status = "monster"
        )
      )
    }
  )


  monData.dt <-
    Monster.dt[, .(MonsterId, Name, MainAtt, SubAtt,
      LvMax, Hp, Atk, Rec, Hp110, Atk110, Rec110, Weighted, Weighted110, ActiveSkillId, LeaderSkillId)]

  monData.dt <- merge(monData.dt, ActiveSkill.dt, by = "ActiveSkillId", all.x = T)

  monData.dt <- merge(monData.dt, LeaderSkill.dt, by = "LeaderSkillId", all.x = T)

  temp <- merge(
    AwokenSkillRelation.dt,
    AwokenSkill.dt[, .(AwokenSkillId, LinkHtml)],
    by = "AwokenSkillId"
  )

  awkSklIconCat.dt <- temp[order(MonsterId, Position)][
    SuperAwoken == 0,
    paste0(LinkHtml, collapse = ""),
    by = MonsterId]

  superASIconCat.dt <- temp[order(MonsterId, Position)][
    SuperAwoken == 1,
    paste0(LinkHtml, collapse = ""),
    by = MonsterId]

  rm(temp)

  temp <- merge(
    TypeRelation.dt,
    Type.dt[, .(TypeId, LinkHtmlL)],
    by = "TypeId"
  )

  typeIconCat.dt <- temp[order(MonsterId)][, paste0(LinkHtmlL, collapse = ""), by = MonsterId]

  rm(temp)

  monData.dt <- merge(monData.dt, awkSklIconCat.dt, by = "MonsterId", all.x = T)
  setnames(monData.dt, "V1", "AwokenSkill")
  monData.dt <- merge(monData.dt, superASIconCat.dt, by = "MonsterId", all.x = T)
  setnames(monData.dt, "V1", "SuperAwokenSkill")
  monData.dt <- merge(monData.dt, typeIconCat.dt, by = "MonsterId", all.x = T)
  setnames(monData.dt, "V1", "Type")

  wuIfNA <- function(x) {
    ifelse(is.na(x), "無", x)
  }

  observeEvent(input$selectMonster, {

    output$monsterDataViewer <- renderUI({

      monSel <- monData.dt[MonsterId == input$selectMonster]
      tagList(
        wellPanel(
          # style = "background:azure;",
          div(
            style = "display:flex; flex-wrap:wrap;",
            div(
              tags$img(
                src = paste0("img/MonsterIcon/", input$selectMonster, ".png"),
                height = '60',
                width = '60'
              )
            ),
            div(
              style = "align-self:center; padding-left:5px; padding-top:5px;",
              tags$b(
                style = "font-size:15px;",
                paste0("No.", monSel$MonsterId, " - ", monSel$Name)
              ),
              div(
                style = "padding-top:5px;",
                HTML(monSel$Type)
              )
            )
          ),
          div(
            style = "padding-top:10px; padding-bottom:5px;",
            tags$b("覺醒技:"),
            HTML(wuIfNA(monSel$AwokenSkill))
          ),
          div(
            style = "padding-bottom:10px;",
            tags$b("超覺醒:"),
            HTML(wuIfNA(monSel$SuperAwokenSkill))
          ),
          renderTable(
            {
              data.table(
                Lv = c(monSel$LvMax, 110L),
                HP = c(monSel$Hp, monSel$Hp110),
                ATK = c(monSel$Atk, monSel$Atk110),
                RCV = c(monSel$Rec, monSel$Rec110),
                Weighted = c(monSel$Weighted, monSel$Weighted110)
              )
            },
            bordered = T,
            spacing = "s",
            sanitize.text.function = identity
          ),
          div(
            style = "display:flex; margin-top:-10px;",
            tags$table(
              style = "width: 304px;",
              tags$tr(
                tags$td(
                  tags$b("主動技能")
                ),
                tags$td(
                  monSel$ActiveSkillName
                ),
                tags$td(
                  "初始CD"
                ),
                tags$td(
                  monSel$MaxCd
                ),
                tags$td(
                  "最短CD"
                ),
                tags$td(
                  monSel$MinCd
                )
              ),
              tags$tr(
                tags$td(
                  style = "text-align: left; font-size: 13px;",
                  colspan = "6",
                  HTML(wuIfNA(monSel$ActiveSkillDescription))
                )
              ),
              tags$tr(
                tags$td(
                  tags$b("隊長技能")
                ),
                tags$td(
                  colspan = "5",
                  wuIfNA(monSel$LeaderSkillName)
                )
              ),
              tags$tr(
                tags$td(
                  style = "text-align: left; font-size: 13px;",
                  colspan = "6",
                  wuIfNA(monSel$LeaderSkillDescription)
                )
              ),
              tags$tr(
                tags$td(
                  "外部鏈接"
                ),
                tags$td(
                  style = "text-align: left; padding-left: 10px;",
                  colspan = "5",
                  tags$a(
                    href = paste0("http://pad.skyozora.com/pets/", monSel$MonsterId),
                    target = "_blank",
                    "戰友網"
                  )
                )
              )
            )
          )
        )
      )

    })

    forAutoScroll$V1 <- forAutoScroll$V1 + 1

  })

  observeEvent(forAutoScroll$V1, {
    if (forAutoScroll$V1>1) {
      session$sendCustomMessage(type = "scrolltoid", message = list("monsterDataViewer"))
    }
  })


  dbDisconnect(con)

}

shinyApp(ui, server)
