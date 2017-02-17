#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  dv <- read.csv("dep_ville.csv", sep=";")
  tmp <- read.csv("depPop.csv")
  deptPop <- 
    tmp %>%
    group_by( cod_dept) %>%
    summarise(superficie=sum(area), pop=sum(pop) ) %>% 
    mutate(ds = 100*ceiling(pop/superficie) ) %>%
    arrange(cod_dept) 
  
  rm(tmp)

  
  p_rds = readRDS("DEPARTEMENT/jym93.Rds")
  p_rds@data = left_join(p_rds@data, deptPop, by=c("CODE_DEPT"="cod_dept"))
  
  comm93 <- readRDS("DEPARTEMENT/comm93.Rds")
  compop <- data.frame (code_ins = comm93$INSEE_COM, 
                        dsty = ceiling(100*as.numeric(levels(comm93$POPULATION))[comm93$POPULATION] 
                                       /as.numeric(levels(comm93$SUPERFICIE))[comm93$SUPERFICIE] ) )
  comm93@data = left_join(comm93@data, compop, by=c("INSEE_COM"="code_ins"))
  
  binpal <- colorBin("YlOrRd", comm93$dsty, 5, pretty = TRUE,alpha = TRUE)
  
  colorpal <- reactive({  colorNumeric("YlOrRd", comm93$dsty) })
  
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
              zoom= 7) 
  })
  
  
  observe({
    leafletProxy("map") %>%
      clearShapes()  %>%
      addPolygons(data = p_rds[ p_rds$CODE_DEPT == input$deptno, ] ,
                  weight = 2,
                  fillColor = "green", 
                  popup = paste(p_rds[ p_rds$CODE_DEPT == input$deptno, ]$NOM_CHF, 
                                as.character(p_rds[ p_rds$CODE_DEPT == input$deptno, ]$Total) )
      ) 
  })
  
  observeEvent(input$frDensity, {
    pxy <- leafletProxy("map", data = comm93[ comm93$CODE_DEPT == input$deptno, ])
    pxy %>%
      #clearControls() %>%
      clearShapes() %>%
      addPolygons(weight = 1,
                  smoothFactor = 0.2, 
                  fillOpacity = 0.8, 
                  color = ~binpal(dsty)
      ) %>%
      #pxy %>%
      clearControls()
    if (input$legend) {
      pal <- colorpal()
      pxy %>% 
        addLegend(position = "bottomright", pal = pal, values = ~ dsty)
    }
    #clearControls()
  })
  
})
