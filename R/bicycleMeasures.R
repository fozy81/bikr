#' @export

#### To work out the impact of proposed or underconstruction cyclepaths and how this affects status
#### 


bicycleMeasures <- function(x){
  
  # x <- scotlandAmsterdam
  current <- bicycleStatus(x)
  current  <- merge(current,x,by.x="features.properties.name",by.y="features.properties.name")
  
 x$features.properties.off_road_cycleway <- x$features.properties.off_road_cycleway + x$features.properties.proposed_off_road_cycleway + x$features.properties.construction_off_road_cycleway
x$features.properties.ncn <- x$features.properties.ncn + x$features.properties.proposed_ncn
 x$features.properties.highways <- x$features.properties.highways + x$features.properties.construction_highways + x$ features.properties.proposed_highways
  
future <- bicycleStatus(x)
future <- merge(future,x,by.x="features.properties.name",by.y="features.properties.name")
  future$change <-  future$'Total normalised' - current$'Total normalised' 

x <- data.frame(cbind(current$features.properties.name,current$features.properties.highways, future$features.properties.highways,current$features.properties.off_road_cycleway,future$features.properties.off_road_cycleway,current$'Indicator total',future$'Indicator total',current$'Total normalised', future$'Total normalised', future$change))
names(x) <- c("Name","Current length of roads","Future length of roads","Current length of cycle paths", "Future length of cycle paths","Current Indicator total", "Future Indicator total","Current Bicycle Quality Ratio","Future Bicycle Quality Ratio","Expect change in ratio")

return(x)

}