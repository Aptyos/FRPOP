library(shiny)
library(leaflet)
library(dplyr)
library(RColorBrewer)

xlib <- c("ggmap", "rgdal", "rgeos", "maptools", "dplyr", "tidyr", "sp", "tmap")
lapply(xlib, library, character.only = TRUE)


library(shiny)

# Define UI for application that draws a histogram
# shinyUI(fluidPage(
shinyUI(bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),  
  sidebarPanel(
    h2("Liste des Departements"),
    selectInput(inputId   = "deptno", 
                label= "Choose a Department Number",
                choices=c("01","02","2A","2B","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19",
                          "2A","2B","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37",
                          "38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56",
                          "57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75",
                          "76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93","94",
                          "95"),        
                selected  = 'All'),
    submitButton("Submit"),
    h4("Nom Departement"),
    textOutput("dep_name"),
    tags$head(tags$style("#dep_name{color: blue; font-size: 12px; font-style: italic; }" ) ),
    h4("Ville Principale"),
    textOutput("city_name"),
    tags$head(tags$style("#city_name{color: blue; font-size: 12px; font-style: italic; }" ) ),
    h4("Latitude et Longitude"),
    textOutput("LatitudeLongitude"),
    tags$head(tags$style("#LatitudeLongitude{color: blue; font-size: 12px; font-style: italic; }" ) ),
    h4("Population Density"),
    textOutput("density"),
    tags$head(tags$style("#density{color: blue; font-size: 12px; font-style: italic; }" ) ),
    actionButton(inputId = "frDensity","Overall Density"),
    checkboxInput("legend", "Show legend", TRUE)
  ),
  # Show a plot of the generated distribution
  mainPanel(
    leafletOutput("map") #, width = "100%", height = "100%")
  )
  
))
