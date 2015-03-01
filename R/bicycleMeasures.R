#' @export

#### To work out the impact of proposed or underconstruction cyclepaths and how this affects status
#### 


bicycleMeasures <- function(x){
  
  # x <- scotlandAmsterdam
  current <- bicycleStatus(x)
  current  <- merge(current,x,by.x="name",by.y="name")
  
 x$cyclepath <- x$cyclepath + x$proposedcyclepath + x$constructioncyclepath
x$routes <- x$routes + x$proposedroutes
 x$road <- x$road + x$constructionroad + x$proposedroad
  
future <- bicycleStatus(x)
future <- merge(future,x,by.x="name",by.y="name")
  future$change <-  future$'Total normalised' - current$'Total normalised' 

x <- data.frame(cbind(current$name,current$road, future$road,current$cyclepath,future$cyclepath,current$'Indicator total',future$'Indicator total',current$'Total normalised', future$'Total normalised', future$change))
names(x) <- c("Name","Current length of roads","Future length of roads","Current length of cycle paths", "Future length of cycle paths","Current Indicator total", "Future Indicator total","Current Bicycle Quality Ratio","Future Bicycle Quality Ratio","Expect change in ratio")

return(x)

}