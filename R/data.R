#' scotlandAmtersdam
#'
#' Summary of OpenStreetMap data prepared by bicycleClass script which can be found
#' in data-raw folder of this package. This summary data can be processed by 
#' by \pkg{bicycleStatus} function. 
#' 
#' @usage bicycleStatus(scotlandAmsterdam)
#'
#' @format A data frame with 11 variables:
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
#' \item{\code{editors}}{Number of openstreetmap editors of bicycle parking}
#' \item{\code{lasteditdate}}{Date of last edit in openstreetmap of bicycle parking}
#' \item{\code{version}}{Number of version of bicycle parking nodes in openstreetmap}
#' }
#'
#' For further details, see \url{http://www.openstreetmap.org}
#'
"scotlandAmsterdam"