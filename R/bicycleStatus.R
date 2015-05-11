#' bicycleStatus
#' 
#' bicycleStatus is used to calculate and classify an index for bicycle
#' infrastructure based on a dataframe of bicycle indicators.
#' 
#' Using the example dataset in this package which uses data from Scotland and
#' compares it against Amsterdam, its possible to see that Amsterdam provides better
#' infrastructure. The Scottish areas are classified based on 5 quintiles
#' on a normalised scale between 0-1 (Amsterdam = 1).
#' 
#' This function is designed to work from indicator values obtained from
#' OpenStreetMap data. Specifically, it has been designed to use the bicycleData
#' function. This function returns a dataframe from an OpenStreetMap database
#' with the arguments required for use with bicycleStatus. Other data sources or
#' supplementary data sources could be used as long as the dataframe is 
#' constructed correctly for this function. There are four indicator ratios of 
#' bicycle infrastructure which are combined to give an overall classification. 
#' These are returned in a dataframe: The ratio of cyclepath length to road 
#' length, ratio of National Cycle Network routes to roads length and the amount
#' of bicycle parking per hectare. The is also a 'ruralness weighting' applied 
#' to account for less densely populated areas which arguably have quieter roads
#' and require less cycle infrastructure. The ruralness weighting is based on the 
#' relative amount of roads to area as a proxy for population density. See 
#' bicycleData function for detailed breakdown of the OpenStreetMap data 
#' required for this function.
#' 
#' Once all indicators are calculated they are given weights for
#' Cyclepath, National Cycle Route and Bicycle parking ratios respectively. This
#' weighting is based on expert opinion and bicycle literature (both of which
#' are deemed to subjective). Further work at linking bicycle indicators on
#' outcomes i.e. the \% of the public travelling using bicycles is planned.
#' Ultimately, the index is base on quantitive data but the final assigned
#' status calculated for an area is based to some degree on the weighting given 
#' to each indicator. The approach is to iterate the classification system to
#' more closely align the overall status classification to
#' socio-ecomonic-enviromental outcomes.
#' 
#' Each entry in the dataframe is also given a 'Sampling effort'. In this
#' context, it measures the sampling effort (number of OpenStreetMap
#' editors) and the time of last edit to represent uncertainty in the
#' quality of the OpenStreetMap data. However, the current method is a fudge but
#' produces figures that appear roughly feasible. Further empirical testing is
#' required to make this robust.
#' 
#' Objectives and measures are calculated to project the amount of improvement
#' required for an area to reach the equivalent status as the highest ranked area
#' within the dataset.
#' @format A data frame with 13 variables - column names must match but column
#'   order not important:
#' \describe{
#' \item{\code{name}}{name or unique id of area}
#' \item{\code{cyclepath}}{length in km of cycle paths}
#' \item{\code{road}}{total length in km of paved roads}
#' \item{\code{bicycleparking}}{number of bicycle parking spaces}
#' \item{\code{area}}{Area in hectares of polygon being assessed}
#' \item{\code{routes}}{length in km of proposed Nation cycle route}
#' \item{\code{proposedroutes}}{length in km of proposed Nation cycle route}
#' \item{\code{proposedcyclepath}}{length in km of proposed cycle path}
#' \item{\code{constructioncyclepath}}{Length in km of cyclepath under construction}
#' \item{\code{editors}}{Number of openstreetmap editors of bicycle parking}
#' \item{\code{lasteditdate}}{Date of last edit in openstreetmap of bicycle parking}
#' \item{\code{proposedhighways}}{length in km of proposed roads}
#' \item{\code{constructionshighways}}{length in km of construction roads}
#' }
#' @usage
#' bicycleStatus(x,amsterdamIndex=TRUE,effort=TRUE,bicycleParkingWeight=1.5,
#' routeWeight=0.8,cyclePathWeight=4,ruralWeight=2)
#'   
#' @param x Dataframe input from bicycleData function 
#' @param effort Estimate sampling effort to assess confidence in data quality
#'   (default=TRUE)
#' @param amsterdamIndex Calculate status relative to data for Amsterdam included in
#'   package (default=TRUE)
#' @param bicycleParkingWeight Variable for weighting of bicycleparking input
#'   variable which is reflected in output 'cyclepath to road ratio norm
#'   weighted' (default=1.5)
#' @param routeWeight Variable for weighting of routes input which is reflected
#'   in output 'bicycle route to road ratio norm' (default=0.8)
#' @param cyclePathWeight Variable for weighting of cyclepath input variable
#'   which is reflected in output 'cycle route to road ratio norm weighted'
#'   (default=4)
#' @param ruralWeight Variable for weighting of ruralness reflected in output
#'   'rural weighting' (default=2)
# @param objectives Calculate required improvements based on objective year and
#   proposed status (default=TRUE)
# @param measures Calculate indicators and status based on proposed and under
#   construction cycle indictators (default=TRUE)
#' @return dataframe containing the following:
#' \describe{
#' \item{\code{name}}{name or unique id of area} 
#' \item{\code{cyclepath to road
#' ratio}}{A ratio of cycle path to road}
#' \item{\code{cyclepath to road ratio
#' norm}}{A ratio of cycle path to road normalised against max value or
#' Amsterdam region (default)}
#' \item{\code{Cycle path status}}{Status of cycle path based
#' on quintiles}
#' \item{\code{cyclepath to road ratio norm weighted}}{A ratio of
#' cycle path to road with * 4 weighting. The cycle path to raod ratio is deemed
#' to be *4 more important than the other indexes}
#' \item{\code{area to bicycle parking ratio}}{The number of cycle parking spaces
#' per hectare}
#' \item{\code{area to bicycle parking ratio norm}}{The number of
#' cycle parking areas per hectare normalised against max value or 
#' Amsterdam region (default). This will be a value between 0-1.0. A value of 1.0
#' is equal to the max. If using amsterdamIndex=TRUE parameter (default), the
#' value is capped at 1.0 even if higher values are produced than the value
#' found in Amsterdam region. The value is capped because the Amsterdam region
#' is being used as the benchmark.}
#' \item{\code{Bicycle parking status}}{Status of bicycle parking based on 
#' quintiles of the normalised score. The five categories are High, Good, 
#' Moderate, Poor or Bad. The boundaries are less than or equal to 0.2 = Bad, 
#' 0.4 = Poor, 0.6 = Moderate, 0.8 = Good, 1.0 = High. For instance, if a 
#' location has 60\% the parking of Amsterdam it will
#' be categorised as 'Moderate'.}
#' \item{\code{rural weighting}}{Rural weighting is a ratio of the length of
#' road divided by area. This gives an idea of the road density within a given
#' area and broadly how rural an area may be. It is thought rural
#' areas will on balance require less bicycle infrastrucutre because quite
#' country roads, for example single lane roads on islands and roads in remote
#' areas, don't require off road cycle paths or cycle lanes to the same extent
#' as busy urban roads.}
#' \item{\code{bicycle route to road ratio}}{A ratio of National Cycle Network route to road length}
#' \item{\code{bicycle route to road ratio norm}}{A normalised ratio of
#' cycle route to road. The normalised value will be between 0-1.0. A value of 1.0
#' is equal to the max. If using amsterdamIndex=TRUE parameter (default), the
#' value is capped at 1.0 even if values higher than Amsterdam region
#' are discovered. The value is capped because the Amsterdam region
#' is being used as the benchmark. Currently having more national cycle network
#' than Amsterdam is seen as superfluous if Amsterdam is accepted as the Gold
#' standard in bicycle infrastructure provision.}
#' \item{\code{National cycle network status}}{Status of National Cycle Network based on
#' quintiles of the normalised score. The five categories are High, Good,
#' Moderate, Poor or Bad. The boundaries are less than or equal to 0.2 = Bad,
#' 0.4 = Poor, 0.6 = Moderate, 0.8 = Good, 1.0 = High. For instance, if a
#' location has 85\% the length of Amsterdam it will
#' categorised as 'High'.}
#' \item{\code{cycle route to road ratio norm weighted}}{A ratio of
#' cycle route to road ratio with * 2 weighting. The cycle path to road ratio is deemed
#' to be *2 more important than the other indexes}
#' \item{\code{Indicator total}}{The Indicator total is the sum of the normalised ratios}
#' \item{\code{Total normalised}}{The Total normalised is the sum of the
#' weighted normalised ratios which is also normalised against the max or
#' Amsterdam Indicator total}
#' \item{\code{Status}}{Status is based on
#' quintiles of the Total normalised value. The five categories are High, Good,
#' Moderate, Poor or Bad. The boundaries are less than or equal to 0.2 = Bad,
#' 0.4 = Poor, 0.6 = Moderate, 0.8 = Good, 1.0 = High. For instance, if a
#' location has 15\%  the Total normalised value of Amsterdam it will be
#' categorised as
#' 'Bad'.}
#' \item{\code{Sampling Effort}}{The Sampling Effort is a percentage estimate of the
#' sampling effort and therefore the quality of the underlying map data. It is
#' based on three features of the bicycle parking data openstreetmap extracted:
#' The average number of versions of each node, the total number of editors and
#' the timestamp of the most recent edit.}
#' \item{\code{Rank}}{A rank 1,2,3...N is attributed to each area. '1'
#' represents the area with the highest 'Total normalised' value}}
#' @examples
#' bicycleStatus(scotlandMsp)
#' bicycleStatus(scotlandMsp[1:10,],amsterdamIndex=FALSE) 
#' @section Warning:
#' Do not operate this function while riding a bicyle
#' @export

# column order (scotlandMsp data):
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
# 12. proposedhighways
# 13. constructionhighways

bicycleStatus <- function(x,amsterdamIndex=TRUE,effort=TRUE, bicycleParkingWeight=1.5,routeWeight=0.8,cyclePathWeight=4,ruralWeight=2){

  #  x <- scotlandAmsterdam for testing
  #  x <- scotlandMsp for testing

  if(amsterdamIndex==TRUE){
    # acquire reference data for Amsterdem region from bikr package to allow relative comparison against Amsterdam values
    scotlandAmsterdam <- scotlandAmsterdam
    # set maxValue to standardise against as Amsterdam 
     maxValue <- function(y) return (y[x$name == 'Stadsregio Amsterdam'])
  }
  if(amsterdamIndex==FALSE){
    # set maxValue to standardise against a max value in list/vector i.e. do not
    # standardised against Amsterdam - but max value across each sub-category
  maxValue <- function(x) return(max(x))
  
  }
  
  #normalised cyclepath ratioweighting
  x$'cyclepath to road ratio' <-   round(x$'cyclepath' / x$'road' ,digits=3)  
  x$'cyclepath to road ratio norm' <- round(x$'cyclepath to road ratio' / maxValue(x$'cyclepath to road ratio') ,digits=3)
  x$'cyclepath to road ratio norm' <- ifelse(x$'cyclepath to road ratio norm'> 1,1,x$'cyclepath to road ratio norm') 
  x$'Cycle path status' <- ifelse(x$'cyclepath to road ratio norm' <= 0.8, "Good", "High")
  x$'Cycle path status' <- ifelse(x$'cyclepath to road ratio norm' <= 0.6, "Moderate",  x$'Cycle path status')
  x$'Cycle path status' <- ifelse(x$'cyclepath to road ratio norm' <= 0.4, "Poor",   x$'Cycle path status')
  x$'Cycle path status' <- ifelse(x$'cyclepath to road ratio norm' <= 0.2, "Bad",   x$'Cycle path status')
  x$'cyclepath to road ratio norm weighted' <- x$'cyclepath to road ratio norm' * cyclePathWeight
  
  # normalised cycleparking   
  x$'area to bicycle parking ratio' <- round(x$'bicycleparking' / x$'area',digits=6) 
  x$'area to bicycle parking ratio norm' <- round(x$'area to bicycle parking ratio' / maxValue(x$'area to bicycle parking ratio'),digits=3)
  x$'area to bicycle parking ratio norm' <-  ifelse( x$'area to bicycle parking ratio norm' > 1,1, x$'area to bicycle parking ratio norm')
  x$'area to bicycle parking ratio norm' <- x$'area to bicycle parking ratio norm' * bicycleParkingWeight
  x$'Bicycle parking status' <- ifelse(x$'area to bicycle parking ratio norm' <= 0.8, "Good", "High")
  x$'Bicycle parking status' <- ifelse(x$'area to bicycle parking ratio norm' <= 0.6, "Moderate",  x$'Bicycle parking status')
  x$'Bicycle parking status' <- ifelse(x$'area to bicycle parking ratio norm' <= 0.4, "Poor",  x$'Bicycle parking status')
  x$'Bicycle parking status' <- ifelse(x$'area to bicycle parking ratio norm' <= 0.2, "Bad",    x$'Bicycle parking status')
  
  # rural weighting
  x$'rural weighting' <- round(round(x$'area' / x$'road',digits=4) / 3000, digits=6) * ruralWeight
  
  # route to road ratio  weighting
  x$'cycle route to road ratio' <- round(x$routes / x$road, digits=3) 
  x$'cycle route to road ratio norm' <- round( x$'cycle route to road ratio'  / maxValue(x$'cycle route to road ratio'),digits=2)
  x$'cycle route to road ratio norm' <-  ifelse( x$'cycle route to road ratio norm' >1 ,1, x$'cycle route to road ratio norm')  
  x$'National cycle network status' <- ifelse(x$'cycle route to road ratio norm' <= 0.8, "Good", "High")
  x$'National cycle network status' <- ifelse(x$'cycle route to road ratio norm' <= 0.6, "Moderate",  x$'National cycle network status')
  x$'National cycle network status' <- ifelse(x$'cycle route to road ratio norm' <= 0.4, "Poor",  x$'National cycle network status')
  x$'National cycle network status' <- ifelse(x$'cycle route to road ratio norm' <= 0.2, "Bad",    x$'National cycle network status')
  
  x$'cycle route to road ratio norm weighted' <- x$'cycle route to road ratio norm'  * routeWeight # weighting
  
  # weighting combined for Overall status 
  x$'Indicator total' <-   round(x$'cyclepath to road ratio norm weighted' +  x$'cycle route to road ratio norm weighted' +  x$'area to bicycle parking ratio norm' + x$'rural weighting', digits=2)
  x$'Total normalised' <- round(x$'Indicator total' /   maxValue(x$'Indicator total'),digits=2)
  
  # Quintiles for status  
  x$'Status' <- ifelse(x$'Total normalised' <= 0.8, "Good", "High")
  x$'Status' <- ifelse(x$'Total normalised' <= 0.6, "Moderate", x$'Status')
  x$'Status' <- ifelse(x$'Total normalised' <= 0.4, "Poor",  x$'Status')
  x$'Status' <- ifelse(x$'Total normalised' <= 0.2, "Bad",   x$'Status')
  if(effort==TRUE){
  # Sampling Effort 
    x$'Sampling Effort editors' <- round(x$editors / x$area, digits=7) 
     x$'Sampling Effort editors norm'  <-  round(x$'Sampling Effort editors' / x$'rural weighting',digits=7)
      x$'Sampling Effort editors norm' <- round( x$'Sampling Effort editors norm' / maxValue(x$'Sampling Effort editors norm'),digits=7)
    x$'Sampling Effort editors norm'  <-  ifelse( x$'Sampling Effort editors norm'  > 1,1, x$'Sampling Effort editors norm' )
    
    x$'Sampling Effort version' <- round(x$version / x$area, digits=7) 
    x$'Sampling Effort version norm'  <-  round(x$'Sampling Effort version' / x$'rural weighting',digits=7)
    x$'Sampling Effort version norm' <- round( x$'Sampling Effort version norm' / maxValue(x$'Sampling Effort version norm'),digits=7)
    x$'Sampling Effort version norm'  <-  ifelse( x$'Sampling Effort version norm'  > 1,1, x$'Sampling Effort version norm')
    
    x$'Sampling Effort' <- as.numeric(as.Date(x$lasteditdate)) - as.numeric(as.Date(maxValue(x$lasteditdate)))
    x$'Sampling Effort'  <-   x$'Sampling Effort' -  (min(x$'Sampling Effort') - 1)
  x$'Sampling Effort' <- round(x$'Sampling Effort' / x$'rural weighting',digits=7)
  x$'Sampling Effort' <- round(x$'Sampling Effort' / maxValue(x$'Sampling Effort') ,digits=6)
  x$'Sampling Effort'  <-  ifelse( x$'Sampling Effort'  > 1,1, x$'Sampling Effort')
 
  x$'Sampling Effort'<- x$'Sampling Effort'  +    x$'Sampling Effort version norm' +     x$'Sampling Effort version norm' 
  x$'Sampling Effort' <- 100 / maxValue(x$'Sampling Effort') * x$'Sampling Effort'
  x$'Sampling Effort' <- unlist(lapply(x$'Sampling Effort',function(y){
    if (y < 30){
            return(y + 30)  # fudge factor for very low scores - could improve...
    }
    else return(y)
  }))
  
  x$'Sampling Effort' <-   paste(round(x$'Sampling Effort',digits=2),"%",sep="")
  }
  
  x$'Description' <- paste("The cycle infrastructure in ", x$name," consists of ",x$cyclepath,
                           "km of cycle path (separated from motor-vehicle traffic), ",x$bicycleparking, 
                           " bicycle parking spaces and ",x$routes,
                           "km of National Cycle Network routes. The ratio of paved road highway to cycle path is ", round(x$'cyclepath to road ratio' * 100,digits=0),
                           "%, this compares to ", round(maxValue(x$'cyclepath to road ratio')* 100,digits=0),"% in ",x$name[x$'cyclepath to road ratio' == maxValue(x$'cyclepath to road ratio')],".",
                           sep="")  
  
  # rank results  
  x <-  x[with(x, order(x$'Total normalised',decreasing = T )), ]
  x$'Rank' <- 1:length(x[,1])

  return(x[,c('name','commutingbybicycle','version','areacode','cyclepath to road ratio','cyclepath to road ratio norm','Cycle path status','cyclepath to road ratio norm weighted','area to bicycle parking ratio','area to bicycle parking ratio norm','Bicycle parking status','rural weighting','cycle route to road ratio','cycle route to road ratio norm','National cycle network status','cycle route to road ratio norm weighted','Indicator total','Total normalised','Status','Sampling Effort version norm','Sampling Effort','Description','Rank')])
}
  
