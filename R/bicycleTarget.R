#' @export

### takes output from bicycleStatus works out how much cycle path needs to be created to reach good status

#summary <- data(scotlandAmsterdam)
#summary <- scotlandAmsterdam
#status <- bicycleStatus(scotlandAmsterdam)
# completion <- 7
# cost <- 150000
#bicycleTarget(summary, status,completion)


bicycleTarget <- function(summary, status,completion, cost){
  
#  x <- rbind(x, scotlandAmsterdam[scotlandAmsterdam[,1] == 'Stadsregio Amsterdam',])
#  maxrow <- length(x[,1])
  
status <-   merge(status,summary,by.x="features.properties.name",by.y="features.properties.name")
  status$'Cycle Path km increase target' <- (status$features.properties.off_road_cycleway * (status$'cyclepath to road ratio'[status[,1] == 'Stadsregio Amsterdam'] / status$'cyclepath to road ratio' ) - status$features.properties.off_road_cycleway ) * 0.8

status$'Cycle Path km increase target' <-  ifelse(status$'Cycle Path km increase target' == "NaN", 0.8 * (status$features.properties.highways * status$'cyclepath to road ratio'[status[,1] == 'Stadsregio Amsterdam']), status$'Cycle Path km increase target')
  
status$'Cycle Path km increase target non-rural bias' <- round(status$'Cycle Path km increase target' ,digits=2)

status$'Cycle Path km increase target' <- round(status$'Cycle Path km increase target' *  (1 - status$'rural weighting') ,digits=2)

status$'Yearly km increase target' <- round( status$'Cycle Path km increase target' / completion,digits=2)
  
status$'Projected Cost per year £M' <- round(status$'Cycle Path km increase target' * (cost/1000000) / completion ,digits=2)

  x <- data.frame(cbind(status[,1],status$'Cycle Path km increase target non-rural bias', status$'Cycle Path km increase target',status$'Yearly km increase target',status$'Projected Cost per year £M' ))
  names(x) <- c("Name","Cycle Path km increase target non-rural bias","Cycle Path km increase target", "Yearly km increase target","Projected Cost per year £M")
return(x)
#  date <- Sys.time()
 # year <- format(date, "%Y")
  
  
}
