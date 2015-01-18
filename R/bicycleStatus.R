#' bicycleStatus
#' 
#' bicycleStatus is used to calculate and classify an index for bicycle infrastructure based on a dataframe of 
#' bicycle indicators. 
#' 
#' For instance, the example dataset in this package uses data from Scotland and compares
#' it against Amsterdam. Unsuprisingly, Amsterdam provides the best infrastructre, the other Scottish
#' areas are classified based on 5 quintiles on a normalised scale between 0-1 (Amsterdam = 1). 
#' 
#' This function is designed to work of value obtained from OpenStreetMap data. Specifically, it has been
#' designed to use the bicycleData function. This function returns a dataframe from an OpenStreetMap
#' database with the arguments required for use with bicycleStatus. Other data sources or
#' supplementary data sources could be used as long as the dataframe is constructed correctly for this function. 
#' There are four indicator ratios of bicycle infrastructure which are combined to give an overall classification.
#' These are return in a dataframe: The ratio of cyclepath length to road length, ratio of National Cycle
#' Network routes to roads length and the amount of bicycle parking per hectare. The is also a
#' 'ruralness weighting' applied to account for less densely populated areas which arguably have quieter roads
#' and require less cycle parking. The ruralness weighting is based on the relative amount of roads to area
#' as a proxy for population density. See bicycleData function for detailed breakdown of the OpenStreetMap
#' data required for this function. 
#' 
#' Once all indicators are calculated they are given weights 4:2:1 for Cyclepath, National Cycle Route
#' and Bicycle parking ratios respectively. This weigthting is based on expert opinion and bicycle literature
#' (both of which are deemed to subjective). Further work at linking bicycle indicators on outcomes i.e. the
#' % of the public travelling using bicycles is planned. Ultimately, the index is base on quantitive data
#' but the final assigned status claculated for an area is based to some degree on the weighting given
#' to each indicator. The approach is to iterate the classification system to include to closely align
#' the status to socio-ecomonic-enviromental outcomes. 
#' 
#' Each entry in the dataframe is also given a 'Confidence of Class'. In this context, it tries to measure
#' the sampling effort (number of OpenStreetMap editors) and the time of last edit to represent uncertainty in the 
#' in the quality of the OpenStreetMap data.  
#' 
#' Objectives and measures are calculated to project the amount of improvement required for a area to reach the equivalent 
#' status as the highest ranked area within the dataset. 
#' @format A dataframe with these name, cyclepath, cycleroutes, road, bicycleparking, area, editors, lasteditdate
#' @usage bicycleStatus(x)
# @example bicycle(scotlandAmsterdam)
#' @param x Dataframe input from bicycleData function including 14 columns (name, cyclepath, cycleroutes,
#' proposedcycleroutes,proposedcyclepath, constructioncyclepath, constructioncycleroutes, road, bicycleparking, area,
#' editors, lasteditdate, objectiveyear, proposedstatus). 
#' @param effort Estimate sampling effort to assess confidence in data quality (default=TRUE)
#' @param amsterdam Calculate status relative to data for Amsterdam included in package (default=FALSE)
#' @param objectives Calculate required improvements based on objective year and proposed status (default=TRUE)
#' @param measures Calculate indicators and status based on proposed and under construction cycle indictators (default=TRUE)
#' @return dataframe
#' @export
#' @seealso bicycleData

# library(jsonlite)
#d <- data.frame(fromJSON('/home/tim/github/cycle-map-stats/Rscript/summary.json',flatten=T))
# d[,c(5,7:8,10:17)]
# name, cyclepath, road, bicycleparking, area, editors, lasteditdate


bicycleStatus <- function(x){
  
  x$'cyclepath to road ratio' <-   round(x$cyclepath / x$road ,digits=3)
  x$'area to bicycle parking ratio' <- round(x$features.properties.bicycle_parking / x$features.properties.area,digits=10)
  x$'rural weighting' <- round(x$features.properties.area / x$features.properties.highways,digits=4) / 3000 
  x$'cycle route to road ratio' <- round(x$features.properties.ncn / x$features.properties.highways, digits=3)
  x$'indicator total' <-   round(x$'cyclepath to road ratio' +  x$'cycle route to road ratio' +  x$'area to bicycle parking ratio' + x$'rural weighting', digits=2)
  x$'total normalised' <- round(x$'indicator total' / max(x$'indicator total'),digits=2)
  x$'status' <- ifelse(x$'total normalised' <= 0.8, "Good", "High")
  x$'status' <- ifelse(x$'total normalised' <= 0.6, "Moderate", x$'Status')
  x$'status' <- ifelse(x$'total normalised' <= 0.4, "Poor",  x$'Status')
  x$'status' <- ifelse(x$'total normalised' <= 0.2, "Bad",   x$'Status')
  return(x)
}



effort <- function(x){
  
  x$'Confidence of class' <- (x$editors + as.numeric(substr(x$lasteditdate,1,4))) - 2010
  x$'Confidence of class' <- (round(x$'Confidence of class' / max(x$'Confidence of class'),digits=2) * 100) + 40 #mhmm the smell of fudge
  x$'Confidence of class' <- ifelse(x$'Confidence of class' > 100,paste("100%"), paste(x$'Confidence of class',"%",sep=""))
  return(x)
} 
