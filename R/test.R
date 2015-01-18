#' max number
#' 
#' Takes in numeric numbers and returns max
#' @param x A numeric vector
#' @return max value from input
#' @export
#' @aliases max,biggestnumber

test <- function(x){
  
  max(x)
}


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
