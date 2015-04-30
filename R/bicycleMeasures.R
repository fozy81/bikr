#' bicycleMeasures
#' 
#' bicycleMeasures is used to calculate future changes to bicycle status based
#' on proposed and under construcation features in OpenStreetMap
#' 
#' The measures to improve cycle infrastrcuture maybe include only increasing in
#' cycle path length. Increases in road length may negatively affect the cycle
#' status. For instance, an increase in road building will lower the overall
#' bicycle status of an area if cycle paths are not increased.
#' @format A data frame with 13 variables - column names must match but column
#'   order not important:
#' \describe{
#' \item{\code{name}}{name or unique id of area}
#' \item{\code{cyclepath}}{length in km of cycle paths}
#' \item{\code{road}}{total length in km of paved roads}
#' \item{\code{bicycleparking}}{number of bicycle parking points}
#' \item{\code{area}}{Area in hectares of polygon being assessed}
#' \item{\code{routes}}{length in km of proposed Nation cycle route}
#' \item{\code{proposedroutes}}{length in km of proposed Nation cycle route}
#' \item{\code{proposedcyclepath}}{length in km of proposed cycle path}
#' \item{\code{constructioncyclepath}}{Length in km of cyclepath under
#' construction}
#' \item{\code{editors}}{Number of openstreetmap editors of bicycle parking}
#' \item{\code{lasteditdate}}{Date of last edit in openstreetmap of bicycle
#' parking}
#' \item{\code{proposedhighways}}{length in km of proposed roads}
#' \item{\code{constructionshighways}}{length in km of construction roads}
#' }
#' @usage
#' bicycleMeasures(x)   
#' @param x Dataframe input from bicycleData function 
#' @return dataframe containing the following:
#' \describe{
#' \item{\code{Name}}{name or unique id of area} 
#' \item{\code{Current length of roads}}{Current road length}
#' \item{\code{Future length of roads}}{Future length of roads based on ways
#' tagged as under construction or proposed in OpenStreetMap}
#' \item{\code{Current length of cycle paths}}{Current length of cycle paths}
#' \item{\code{Future length of cycle paths}}{Future length of cycle paths based
#' on ways tagged as under construction or proposed in OpenStreetMap}
#' \item{\code{Current Indicator total}}{Current Indicator total}
#' \item{\code{Future Indicator total}}{Future Indicator total}
#' \item{\code{Current Bicycle Quality Ratio}}{Current Bicycle Quality Ratio}
#' \item{\code{Future Bicycle Quality Ratio}}{Future Bicycle Quality Ratio}
#' \item{\code{Expected change in ratio}}{Expected change in ratio}
#' }
#' @examples
#' bicycleMeasures(scotlandMsp)
#' @section Warning:
#' Do not operate this function while riding a bicyle or feeling drowsy
#' @export

#### To work out the impact of proposed or underconstruction cyclepaths and how this affects status


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
names(x) <- c("Name","Current length of roads","Future length of roads","Current length of cycle paths", "Future length of cycle paths","Current Indicator total", "Future Indicator total","Current Bicycle Quality Ratio","Future Bicycle Quality Ratio","Expected change in ratio")

return(x)

}