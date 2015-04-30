#' scotlandCouncil
#'
#' Summary of OpenStreetMap data prepared by bicycleClass script which can be found
#' in data-raw folder of this package. This summary data can be processed 
#' by \pkg{bicycleStatus} function. This object contains summary data from 
#' council areas to make display easier in the shiny example. It is probably
#' possible to use just a single file in the form of scotland Amsterdam.
#' 
#' @usage scotlandCouncil
#'
#' @format A data frame with 14 variables:
#' \describe{
#' \item{\code{name}}{name of area}
#' \item{\code{areacode}}{name or unique id of area}
#' \item{\code{code}}{type of area e.g. city, council etc}
#' \item{\code{cyclepath}}{length in km of cyclepaths}
#' \item{\code{road}}{total length in km of paved roads}
#' \item{\code{bicycleparking}}{number of bicycle parking points form openstreetmap}
#' \item{\code{area}}{Area in hectares of polygon being assessed}
#' \item{\code{routes}}{length in km of proposed Nation cycle route}
#' \item{\code{proposedroutes}}{length in km of proposed National cycle route}
#' \item{\code{proposedroad}}{length in km of proposed roads}
#' \item{\code{constructionroad}}{length in km of roads under construction}
#' \item{\code{proposedcyclepath}}{length in km of proposed cyclepath}
#' \item{\code{constructioncyclepath}}{Length in km of cyclepath underconstruction}
#' \item{\code{editors}}{Number of openstreetmap editors of bicycle parking}
#' \item{\code{lasteditdate}}{Date of last edit in openstreetmap of bicycle parking}
#' \item{\code{version}}{Number of version of bicycle parking nodes in openstreetmap}
#' \item{\code{commutingbybicycle}}{Percentage of total daily commuters using bicycles - sourced from census}
#' }
#'
#' For further details, see \url{http://www.openstreetmap.org}
#'
"scotlandCouncil"