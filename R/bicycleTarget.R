#' bicycleTarget
#' 
#' bicycleTarget is used to calculate how much it would cost to reach 80\% of the
#' status of Amsterdam within a given time period
#' 
#' The time target is set in years and the cost is calculated by comparing the
#' amount of extra bycle path which would need to be built to create road to
#' cycle path ratio to 80\% of the ratio found in Amsterdam. The average cost is
#' set a 200000 GBP per km as default. This is based on the cost of building cycle
#' paths in London. The cost can be varied.
#' @usage
#' bicycleTarget(summary,status,completion=7, cost=150000)   
#' @param summary Dataframe input from bicycleData function 
#' @param status Dataframe input from bicycleStatus function 
#' @param completion Numeric value for years to completion 
#' @param cost Numeric cost per km
#' @return dataframe containing the following:
#' \describe{
#' \item{\code{Name}}{name or unique id of area} 
#' \item{\code{Cycle Path km increase target non-rural bias}}{Cycle Path km increase target non-rural bias}
#' \item{\code{Cycle Path km increase target}}{Cycle Path km increase target}
#' \item{\code{Yearly km increase target}}{Yearly km increase target}
#' \item{\code{Projected Cost per year GBP}}{Projected Cost per year GBP}
#' }
#' @examples
#' bicycleTarget(scotlandMsp,bicycleStatus(scotlandMsp))
#' @section Warning:
#' Do not operate this function while juggling swords
#' @export

## This needs testing:
# bicycleTarget(scotlandMsp[1:10,],bicycleStatus(scotlandMsp[1:10,],amsterdamIndex=FALSE)) 
### takes output from bicycleStatus works out how much cycle path needs to be created to reach good status

#summary <- data(scotlandAmsterdam)
#summary <- scotlandAmsterdam
#status <- bicycleStatus(scotlandAmsterdam)
# completion <- 7
# cost <- 150000
#bicycleTarget(summary, status,completion)


bicycleTarget <- function(summary, status,completion=7, cost=150000){
  
#  x <- rbind(x, scotlandAmsterdam[scotlandAmsterdam[,1] == 'Stadsregio Amsterdam',])
#  maxrow <- length(x[,1])
  
status <-   merge(status,summary,by.x="name",by.y="name")
  status$'Cycle Path km increase target' <- (status$cyclepath * (status$'cyclepath to road ratio'[status[,1] == 'Stadsregio Amsterdam'] / status$'cyclepath to road ratio' ) - status$cyclepath ) * 0.8

status$'Cycle Path km increase target' <-  ifelse(status$'Cycle Path km increase target' == "NaN", 0.8 * (status$road * status$'cyclepath to road ratio'[status[,1] == 'Stadsregio Amsterdam']), status$'Cycle Path km increase target')
  
status$'Cycle Path km increase target non-rural bias' <- round(status$'Cycle Path km increase target' ,digits=2)

status$'Cycle Path km increase target' <- round(status$'Cycle Path km increase target' *  (1 - status$'rural weighting') ,digits=2)

status$'Yearly km increase target' <- round( status$'Cycle Path km increase target' / completion,digits=2)
  
status$'Projected Cost per year GBP' <- round(status$'Cycle Path km increase target' * (cost/1000000) / completion ,digits=2)

  x <- data.frame(cbind(status[,1],status$'Cycle Path km increase target non-rural bias', status$'Cycle Path km increase target',status$'Yearly km increase target',status$'Projected Cost per year GBP' ))
  names(x) <- c("Name","Cycle Path km increase target non-rural bias","Cycle Path km increase target", "Yearly km increase target","Projected Cost per year GBP")
return(x)
#  date <- Sys.time()
 # year <- format(date, "%Y")
  
  
}
