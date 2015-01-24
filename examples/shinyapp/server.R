library(leaflet)
#library(jsonlite)
library(RJSONIO)
library(bikr)
library(ggplot2)

d <- bicycleStatus(scotlandAmsterdam)
d$fillcolor <- ifelse(d$status == "High","#ffffb2","")
d$fillcolor <- ifelse(d$status == "Good","#fecc5c",d$fillcolor)
d$fillcolor <- ifelse(d$status == "Moderate","#fd8d3c",d$fillcolor)
d$fillcolor <- ifelse(d$status == "Poor","#f03b20",d$fillcolor)
d$fillcolor <- ifelse(d$status == "Bad","#bd0026",d$fillcolor)

#d <- data.frame(fromJSON('/home/tim/github/cycle-map-stats/Rscript/summary.json',flatten=T))
#geojsonFile <- fromJSON('examples/shinyapp/scotlandAmsterdam.json')
#fileName <- fromJSON'scotlandAmsterdam.json'
#geojsonFile <- readChar(fileName, file.info(fileName)$size)


geojsonFile <- RJSONIO::fromJSON('scotlandAmsterdam.json')

shinyServer(function(input, output, session) {
  
  map <- createLeafletMap(session, "map")
  
  session$onFlushed(once=TRUE, function() {
  
    for (i in 1:length(d[,1])){
          
      geojsonFile$features[[i]]$properties$style   <-  list(weight = 5, stroke = "true",
                                 fill = "true", opacity = 1,
                                fillOpacity = 0.4, color= paste(d$fillcolor[d$features.properties.name == geojsonFile$features[[i]]$properties$name]),
                                fillColor = paste(d$fillcolor[d$features.properties.name == geojsonFile$features[[i]]$properties$name]))
    }
    map$addGeoJSON(geojsonFile)
    })
  
  
  values <- reactiveValues(selectedFeature = NULL)
  
  observe({
    evt <- input$map_click
    if (is.null(evt))
      return()
    
    isolate({
      # An empty part of the map was clicked.
      # Null out the selected feature.
      values$selectedFeature <- NULL
    })
  })
  
  observe({
    evt <- input$map_geojson_click
    if (is.null(evt))
      return()
    
    isolate({
      # A GeoJSON feature was clicked. Save its properties
      # to selectedFeature.
      values$selectedFeature <- evt$properties
    })
  })
  
  output$details <- renderText({
    # Render values$selectedFeature, if it isn't NULL.
    if (is.null(values$selectedFeature))
      return(NULL)
    
    as.character(tags$div(
      tags$h3(values$selectedFeature$name),
      tags$div(
        "Region:",
        values$selectedFeature$name,hr(),
        "Bicycle path:",d$status[d[,1] == values$selectedFeature$name]
       
      )
    ))
  })
  
  
  output$table <- renderDataTable({
  
    data <- data.frame(cbind(names(d[c(20,21,22)]), t(d[d[,1] == values$selectedFeature$name,c(20,21,22)])))
    data <- data.frame("Quality Element"=data[,1],"Value"=data[,2])
    data
  },options = list(searching = FALSE,paging = FALSE))
 
# out use dimple library: doesn't render correctly:
#   output$chart2 <- renderChart2({
#    
#     d$'Name' <- d$features.properties.name
#     d <- d[d$'Name' == values$selectedFeature$name | d$'Name' == 'Stadsregio Amsterdam', ]
#       p2 <- dPlot(
#       x = "Name",
#       y = "BQR total",
#       data = d,
#       type = "bar",
#       bounds = list(x = 50, y = 50, height = 250, width = 300)
#     )
#         p2$set(dom = "chart2")
#                return(p2)
#   })

  output$chart2 <- renderPlot({
    d <- d[d[,1] == values$selectedFeature$name | d[,1] == 'Stadsregio Amsterdam', ]
    
    ifelse(is.null(values$selectedFeature$name), p2 <- NULL,
    p <-  qplot(x = d[,1],  y = d[,20], geom="bar",stat="identity",fill=d[,1],xlab="City",ylab="Bicycle Quality Ratio")) 
    p <- p + scale_fill_manual(values= sort(d[,23],decreasing=F), name="City", labels=sort(d[,1],decreasing=F))
    return(p)
    
  })

})


#d$features.properties.name == 'Aberdeen Donside P Const',]
# d[d$features.properties.name == 'Aberdeen Donside P Const' | d$features.properties.name == 'Stadsregio Amsterdam',c(5,24) ]
