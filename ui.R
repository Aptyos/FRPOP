#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI
shinyUI( 
  fluidPage(
  
  # Application title
  titlePanel("French Population in 2016"),
  
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
)
