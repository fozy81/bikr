#' @export

### takes output from bicycleStatus works out how much cycle path needs to be created to reach good status

#summary <- data(scotlandAmsterdam)
#summary <- scotlandAmsterdam
#status <- bicycleStatus(scotlandAmsterdam)
# completion <- 7

#bicycleTarget(summary, status,completion)


bicycleTarget <- function(summary, status,completion, cost){
  
#  x <- rbind(x, scotlandAmsterdam[scotlandAmsterdam[,1] == 'Stadsregio Amsterdam',])
#  maxrow <- length(x[,1])
  
status <-   merge(status,summary,by.x="features.properties.name",by.y="features.properties.name")
  status$'Cycle Path km Target' <- (status$features.properties.off_road_cycleway * (status$'cyclepath to road ratio'[status[,1] == 'Stadsregio Amsterdam'] / status$'cyclepath to road ratio' ) - status$features.properties.off_road_cycleway ) * 0.8

status$'Cycle Path km Target' <-  ifelse(status$'Cycle Path km Target' == "NaN", 0.8 * (status$features.properties.highways * status$'cyclepath to road ratio'[status[,1] == 'Stadsregio Amsterdam']), status$'Cycle Path km Target')
  
status$'Cycle Path km Target non-rural bias' <- round(status$'Cycle Path km Target' ,digits=2)

status$'Cycle Path km Target' <- round(status$'Cycle Path km Target' *  (1 - status$'rural weighting') ,digits=2)

status$'Yearly km target' <- round( status$'Cycle Path km Target' / completion,digits=2)
  
status$'Cycle Path Cost per year £M' <- round(status$'Cycle Path km Target' * (cost/1000000) / completion ,digits=2)

  x <- data.frame(cbind(status[,1],status$'Cycle Path km Target non-rural bias', status$'Cycle Path km Target',status$'Yearly km target',status$'Cycle Path Cost per year'))
  names(x) <- c("Name","Cycle Path km Target non-rural bias","Cycle Path km Target", "Yearly km Target","Cycle Path Cost per year £M")
return(x)
#  date <- Sys.time()
 # year <- format(date, "%Y")
  
  
}
