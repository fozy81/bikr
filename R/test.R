#' bicycleClass
#' 
#' bicycleClass is used to calculate and classify an index for bicycle infrastructure based on a dataframe of 
#' bicycle indicators. 
#' 
#' For instance, the example dataset in this package uses data from Scotland and compares
#' it against Amsterdam. Unsuprisingly, Amsterdam provides the best infrastructre, the other Scottish
#' areas are classified based on 5 quintiles on a normalised scale between 0-1 (Amsterdam = 1). 
#' 
#' This function is designed to work of value obtained from OpenStreetMap data. Specifically, it has been
#' designed to use the bicyclePostGis function. This function returns a dataframe from an OpenStreetMap
#' database with the arguments required for use with bicycleClass. Other data sources or
#' supplementary data sources could be used as long as the dataframe is constructed correctly for this function. 
#' There are four indicator ratios of bicycle infrastructure which are combined to give an overall classification.
#' These are return in a dataframe: The ratio of cyclepath length to road length, ratio of National Cycle
#' Network routes to roads length and the amount of bicycle parking per hectare. The is also a
#' 'ruralness weighting' applied to account for less densely populated areas which arguably have quieter roads
#' and require less cycle parking. The ruralness weighting is based on the relative amount of roads to area
#' as a proxy for population density. See bicyclePostGis function for detailed breakdown of the OpenStreetMap
#' data required for this function. 
#' 
#' Once all indicators are calculated they are given weights 4:2:1 for Cyclepath, National Cycle Route
#' and Bicycle parking ratios respectively. This weigthting is based on expert opinion, bicycle literature
#' (subjective). Further work at linking bicycle indicators on outcomes i.e. the % of the public travelling
#' using bicycles is planned.
#' 
#' Each entry in the dataframe is also given a 'Confidence of Class'. In this context, it tries to measure
#' the sampling effort (number of OpenStreetMap editors) and the time of last edit to represent uncertainty in the 
#' in the quality of the OpenStreetMap data.  
#' @usage bicycleClass(name, cyclepath, road, bicycleparking, area, editors, lasteditdate)
#' @param name character 
#' @param cyclepath length in km
#' @param road length in km
#' @param bicycleparking count of parking points
#' @param area hectares
#' @param editors total number editors of bicycle parking (optional)
#' @param lasteditdate Date of last edit of bicycleparking points (optional)
#' @return dataframe 
#' @export
#' @seealso bicyclePostGis


#d <- data.frame(fromJSON('/home/tim/github/cycle-map-stats/Rscript/summary.json',flatten=T))

bicycleClass <- function(x){
  
  x$'Road Vs cycle path' <-   round(x$features.properties.off_road_cycleway / x$features.properties.highways,digits=3)
  x$'Bicycle parking to area' <- round(x$features.properties.bicycle_parking / x$features.properties.area,digits=10)
  x$'Ruralness weighting' <- round(x$features.properties.area / x$features.properties.highways,digits=4) / 3000 
  x$'NCN Vs highway' <- round(x$features.properties.ncn / x$features.properties.highways, digits=3)
  x$'BQR total' <-   round(x$'Road Vs cycle path' +  x$'NCN Vs highway' +  x$'Bicycle parking to area' + x$'Ruralness weighting', digits=2)
  x$'BQR normalised' <- round(x$'BQR total' / max(x$'BQR total'),digits=2)
  x$'Status' <- ifelse(x$'BQR normalised' <= 0.8, "Good", "High")
  x$'Status' <- ifelse(x$'BQR normalised' <= 0.6, "Moderate", x$'Status')
  x$'Status' <- ifelse(x$'BQR normalised' <= 0.4, "Poor",  x$'Status')
  x$'Status' <- ifelse(x$'BQR normalised' <= 0.2, "Bad",   x$'Status')
  return(x)
}

#d$'Bicycle parking points' <- d$features.properties.bicycle_parking
#d$'Name' <- d$features.properties.name
#d <- bicycleClass(d)

CoC <- function(x){
  
  x$'Confidence of class' <- (x$features.properties.editors + as.numeric(substr(x$features.properties.edit_date,1,4))) - 2010
  x$'Confidence of class' <- (round(x$'Confidence of class' / max(x$'Confidence of class'),digits=2) * 100) + 40 #mhmm the smell of fudge
  x$'Confidence of class' <- ifelse(x$'Confidence of class' > 100,paste("100%"), paste(x$'Confidence of class',"%",sep=""))
  return(x)
} 
