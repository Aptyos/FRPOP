library(shiny)
library(leaflet)
library(dplyr)
library(RColorBrewer)
library(ggmap)  
library(rgdal) 
library(rgeos)
library(maptools)
library(tidyr)
library(sp)

dv <- read.csv("dep_ville.csv", sep=";")

tmp <- read.csv("depPop.csv")
deptPop <-
  tmp %>%
  group_by( cod_dept) %>%
  summarise(superficie=sum(area), pop=sum(pop) ) %>%
  mutate(ds = 100*ceiling(pop/superficie) ) %>%
  arrange(cod_dept)

rm(tmp)

# Define UI
ui <- fluidPage(
   sidebarPanel(
    width = 2,
    h3("Departements"),
    selectInput(inputId="deptno",
                label= "Department Number",
                choices=c("01","02","2A","2B","03","04","05","06","07","08","09",c(10:95)),
                selected  = "75"),
    h4("Departement Name"),
    textOutput("dep_name"),
    tags$head(tags$style("#dep_name{color: blue; font-size: 12px; font-style: italic; }" ) ),
    h4("Main City"),
    textOutput("city_name"),
    tags$head(tags$style("#city_name{color: blue; font-size: 12px; font-style: italic; }" ) ),
    h4("Latitude and Longitude"),
    textOutput("LatitudeLongitude"),
    tags$head(tags$style("#LatitudeLongitude{color: blue; font-size: 12px; font-style: italic; }" ) ),
    h4("Average Dept. Density"),
    textOutput("density"),
    tags$head(tags$style("#density{color: blue; font-size: 12px; font-style: italic; }" ) ),
    # checkboxInput(inputId = "legend", "Show legend", TRUE),
    checkboxInput(inputId = "frDensity","Overall Density",value= FALSE),
    h4(""),
    submitButton("Submit")
  ),
  # Show a plot of the generated distribution
  mainPanel(
     leafletOutput("map", width = 700, height = 700) #, width = "100%", height = "100%")
  )
)

# Define server logic
server <- shinyServer(function(input, output) {

  p_rds = readRDS("jym93.Rds")
  p_rds@data = left_join(p_rds@data, deptPop, by=c("CODE_DEPT"="cod_dept"))

  comm93 <- readRDS("comm93.Rds")
  compop <- data.frame (code_ins = comm93$INSEE_COM,
                        dsty = 100*as.numeric(levels(comm93$POPULATION))[comm93$POPULATION]
                                       /as.numeric(levels(comm93$SUPERFICIE))[comm93$SUPERFICIE] )
  comm93@data = left_join(comm93@data, compop, by=c("INSEE_COM"="code_ins"))

  binpal <- colorBin("YlOrRd", comm93$dsty, 5, pretty = TRUE,alpha = TRUE)

  colorpal <- reactive({ colorNumeric("YlOrRd", comm93$dsty) })

  output$dep_name <- renderText({
    paste(p_rds[p_rds$CODE_DEPT==input$deptno,]$NOM_DEPT," ")
  })

  output$city_name <- renderText({
    paste(dv[dv$CODE_DEPT==input$deptno,]$NOM_CHF," ")
  })

  output$LatitudeLongitude <- renderText({
    paste(dv[ dv$CODE_DEPT== input$deptno,]$latitude,dv[ dv$CODE_DEPT== input$deptno,]$longitude)
  })

  output$density <- renderText({
    v_pop=deptPop[ deptPop$cod_dept== input$deptno,]$pop
    v_area=deptPop[ deptPop$cod_dept== input$deptno,]$superficie
    round(v_pop/v_area,2)*100
  })

  output$map = renderLeaflet({
    leaflet()     %>%
    addTiles()    %>%
    setView(lng = dv[ dv$CODE_DEPT== input$deptno,]$longitude,
            lat = dv[ dv$CODE_DEPT== input$deptno,]$latitude ,
            zoom= 9)
  })


  observe({

    if (input$frDensity == 0 ) {

      leafletProxy("map") %>%
      clearShapes()  %>%
      addCircles(lng=dv[dv$CODE_DEPT== input$deptno,]$longitude, lat=dv[ dv$CODE_DEPT== input$deptno,]$latitude, weight =12, color= "red")  %>%
      addPolygons(data = p_rds[ p_rds$CODE_DEPT == input$deptno, ] ,
                  weight = 2, fillColor = "green",
                  popup = paste(p_rds[ p_rds$CODE_DEPT == input$deptno, ]$NOM_CHF,
                                as.character(p_rds[ p_rds$CODE_DEPT == input$deptno, ]$Total) )
                                    )

    } else {
        pxy <- leafletProxy("map", data = comm93[ comm93$CODE_DEPT == input$deptno, ])
        pxy %>%
          clearShapes() %>%
          addPolygons(weight = 1,
                      smoothFactor = 0.2,
                      fillOpacity = 0.8,
                      color = ~binpal(dsty)
                     ) %>%
          clearControls()
          pal <- colorpal()

        pxy %>%
          addLegend(position = "bottomright", pal = pal, values = ~ dsty, title="Area Density", opacity =1.5)

    }
  })

}) # END SERVER

# Run the application
shinyApp(ui, server)

