#' bicycleStatus
#' 
#' bicycleStatus is used to calculate and classify an index for bicycle
#' infrastructure based on a dataframe of bicycle indicators.
#' 
#' For instance, the example dataset in this package uses data from Scotland and
#' compares it against Amsterdam. Unsuprisingly, Amsterdam provides the best
#' infrastructre, the other Scottish areas are classified based on 5 quintiles
#' on a normalised scale between 0-1 (Amsterdam = 1).
#' 
#' This function is designed to work of value obtained from OpenStreetMap data.
#' Specifically, it has been designed to use the bicycleData function. This
#' function returns a dataframe from an OpenStreetMap database with the
#' arguments required for use with bicycleStatus. Other data sources or 
#' supplementary data sources could be used as long as the dataframe is
#' constructed correctly for this function. There are four indicator ratios of
#' bicycle infrastructure which are combined to give an overall classification. 
#' These are return in a dataframe: The ratio of cyclepath length to road
#' length, ratio of National Cycle Network routes to roads length and the amount
#' of bicycle parking per hectare. The is also a 'ruralness weighting' applied
#' to account for less densely populated areas which arguably have quieter roads
#' and require less cycle parking. The ruralness weighting is based on the
#' relative amount of roads to area as a proxy for population density. See
#' bicycleData function for detailed breakdown of the OpenStreetMap data
#' required for this function.
#' 
#' Once all indicators are calculated they are given weights 4:2:1 for
#' Cyclepath, National Cycle Route and Bicycle parking ratios respectively. This
#' weigthting is based on expert opinion and bicycle literature (both of which
#' are deemed to subjective). Further work at linking bicycle indicators on
#' outcomes i.e. the % of the public travelling using bicycles is planned.
#' Ultimately, the index is base on quantitive data but the final assigned
#' status claculated for an area is based to some degree on the weighting given 
#' to each indicator. The approach is to iterate the classification system to
#' include to closely align the status to socio-ecomonic-enviromental outcomes.
#' 
#' Each entry in the dataframe is also given a 'Confidence'. In this
#' context, it tries to measure the sampling effort (number of OpenStreetMap
#' editors) and the time of last edit to represent uncertainty in the
#' quality of the OpenStreetMap data. However, the current method is a fudge but
#' produce figures that appear roughly feasible. Further empirical testing
#' required to make this robust.
#' 
#' Objectives and measures are calculated to project the amount of improvement
#' required for a area to reach the equivalent status as the highest ranked area
#' within the dataset.
#' @format A data frame with 11 variables in this column order:
#' \describe{
#' \item{\code{name}}{name or unique id of area}
#' \item{\code{cyclepath}}{length in km of cyclepaths}
#' \item{\code{road}}{total length in km of paved roads}
#' \item{\code{bicycleparking}}{number of bicycle parking points form openstreetmap}
#' \item{\code{area}}{Area in hectares of polygon being assessed}
#' \item{\code{routes}}{length in km of proposed Nation cycle route}
#' \item{\code{proposedroutes}}{length in km of proposed Nation cycle route}
#' \item{\code{proposedcyclepath}}{length in km of proposed cyclepath}
#' \item{\code{constructioncyclepath}}{Length in km of cyclepath underconstruction}
#' \item{\code{editors}}{Numer of openstreetmap editors}
#' \item{\code{lasteditdate}}{Date of last edit in openstreetmap}
#' }
#' @usage bicycleStatus(x)
# @example  \dontrun{scotlandAmsterdam}
#' @param x Dataframe input from bicycleData function 
#' @param effort Estimate sampling effort to assess confidence in data quality
#'   (default=TRUE)
#' @param amsterdamIndex Calculate status relative to data for Amsterdam included in
#'   package (default=FALSE)
#' @param objectives Calculate required improvements based on objective year and
#'   proposed status (default=TRUE)
#' @param measures Calculate indicators and status based on proposed and under
#'   construction cycle indictators (default=TRUE)
#' @return dataframe
#' @export

# column order:
# 1. name
# 2. cyclepath
# 3. road
# 4. bicycleparking
# 5. area
# 6. routes
# 7. proposedroutes
# 8. proposedcyclepath, 
# 9. constructioncyclepath
# 10 editors
# 11.lasteditdate


bicycleStatus <- function(x){
  # load in reference data from bikr package data 
  data(scotlandAmsterdam)
  scotlandAmsterdam
  #  x <-    scotlandAmsterdam for testing
  # merge data from Amsterdam with incoming data.frame so Amsterdam Index can be calculated   
  x <- rbind(x, scotlandAmsterdam[scotlandAmsterdam[,1] == 'Stadsregio Amsterdam',])
  maxrow <- length(x[,1])
  # cyclepath ratio  
  x$'cyclepath to road ratio' <-   round(x[,2] / x[,3] ,digits=3)
  
  #normalised cyclepath ratio * 4 weighting  
  x$'cyclepath to road ratio norm' <- round(x$'cyclepath to road ratio' / x[maxrow,12],digits=3)
  x$'cyclepath to road ratio norm' <- ifelse(x$'cyclepath to road ratio norm'> 1,1,x$'cyclepath to road ratio norm') * 4
  
  # cycleparking  
  x$'area to bicycle parking ratio' <- round(x[,4] / x[,5],digits=6) 
  
  # normalised cycleparking  
  x$'area to bicycle parking ratio norm' <- round(x$'area to bicycle parking ratio' / x[maxrow,14],digits=2)
  x$'area to bicycle parking ratio norm' <-  ifelse( x$'area to bicycle parking ratio norm' > 1,1, x$'area to bicycle parking ratio norm')
  # rural weighting * 2
  x$'rural weighting' <- round(round(x[,5] / x[,3],digits=4) / 3000, digits=6) * 2
  
  # route to road ratio  
  x$'cycle route to road ratio' <- round(x[,6] / x[,3], digits=3) 
  
  # route normalised * 2 weighting  
  x$'cycle route to road ratio norm' <- round(x$'cycle route to road ratio' / x[maxrow,17],digits=2)
  x$'cycle route to road ratio norm' <-  ifelse( x$'cycle route to road ratio norm' >1 ,1, x$'cycle route to road ratio norm')   * 2

  # 4:2:1 weighting combined for Overall  
  x$'indicator total' <-   round(x$'cyclepath to road ratio norm' +  x$'cycle route to road ratio norm' +  x$'area to bicycle parking ratio norm' + x$'rural weighting', digits=2)
  x$'total normalised' <- round(x$'indicator total' / x[maxrow,19],digits=2)
  
  # Quintiles for status  
  x$'status' <- ifelse(x$'total normalised' <= 0.8, "Good", "High")
  x$'status' <- ifelse(x$'total normalised' <= 0.6, "Moderate", x$'status')
  x$'status' <- ifelse(x$'total normalised' <= 0.4, "Poor",  x$'status')
  x$'status' <- ifelse(x$'total normalised' <= 0.2, "Bad",   x$'status')
  
  # Confidence needs reworking/refactoring e.g. add an area size biase instead of this fudge:  
  x$'Confidence' <- (x[,10] + as.numeric(substr(x[,11],1,4))) - 2010 
  x$'Confidence' <- (round(x$'Confidence' / max(x$'Confidence'),digits=2) * 100) + 40 #mmmmh smell the fudge
  x$'Confidence' <- ifelse(x$'Confidence' > 100,paste("100%"), paste(x$'Confidence',"%",sep="")) 

  x  <-  x[1:maxrow-1,] # remove Amsterdam from dataframe before returning?? not sure if necessary
  return(x)
}


