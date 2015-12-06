#' Query bicycle data from a database which uses the osm2postgresql schema with all tags h-store activated. 
#' 
#' requires OGR2OGR command line tool and access to osm2postgesql database schema
#' @usage bicycleStatus(user=user, password=password, dbname=dbname, host=host)
#' @param user postgres user name
#' @param password postres password 
#' @param dbname potsgres database name
#' @param host 'localhost' or port


#### Still in development! Currently  used as rough script not function ####
### Needs tidy up - lots of bad code!###

#### This file describes how to download data for OpenStreetMap into  postgres database

### To do
# 0. The Db side can all go in Docker container if anyone wants to reproduce
# 1. Docker postgis database makfile
# 2. makefile to download OSM data + areas
# 3. makefile to create postGIS db
# 4. Query database
# 5. Save summary area data into R package


### OSM data

system("mkdir /home/tim/R/postGISupdate")

setwd("/home/tim/R/postGISupdate")

download.file("http://download.geofabrik.de/europe/great-britain/scotland-latest.osm.bz2",
              "scotland-latest.osm.bz2")

system("bzip2 -d /home/tim/R/postGISupdate/scotland-latest.osm.bz2")

download.file("https://s3.amazonaws.com/metro-extracts.mapzen.com/amsterdam_netherlands.osm.bz2", "amsterdam_netherlands.osm.bz2",method="curl")

system("bzip2 -d /home/tim/R/postGISupdate/amsterdam_netherlands.osm.bz2")


download.file("https://s3.amazonaws.com/metro-extracts.mapzen.com/seville_spain.osm.bz2", "seville_spain.osm.bz2",method="curl")

system("bzip2 -d /home/tim/R/postGISupdate/seville_spain.osm.bz2")

download.file("https://s3.amazonaws.com/metro-extracts.mapzen.com/prague_czech-republic.osm.bz2", "prague_czech-republic.osm.bz2",method="curl")

system("bzip2 -d /home/tim/R/postGISupdate/prague_czech-republic.osm.bz2")


download.file("https://s3.amazonaws.com/metro-extracts.mapzen.com/copenhagen_denmark.osm.bz2", "copenhagen_denmark.osm.bz2",method="curl")

system("bzip2 -d /home/tim/R/postGISupdate/copenhagen_denmark.osm.bz2")


### Install into postGIS

system("osmosis --rx /home/tim/R/postGISupdate/scotland-latest.osm --rx /home/tim/R/postGISupdate/amsterdam_netherlands.osm --rx /home/tim/R/postGISupdate/seville_spain.osm --rx /home/tim/R/postGISupdate/prague_czech-republic.osm --rx /home/tim/R/postGISupdate/copenhagen_denmark.osm --merge --merge --merge --merge --wx merged.osm")
system("osm2pgsql -j -x -s -U tim -S /home/tim/Documents/default.style -d gis2 /home/tim/R/postGISupdate/merged.osm")

system("rm -r /home/tim/R/postGISupdate")

#### database details
library(RPostgreSQL)
# dbname <- "gis2"
# user <- "tim"
# password <- "postgres"
# password <- scan("/home/tim/Documents/key/Untitled Document 1.pgpass", what="")
# host <- "localhost"
# con <- dbConnect(dbDriver("PostgreSQL"), user="username",
#              password=password, dbname=dbname, host=host,port=5432)

con <- dbConnect(dbDriver("PostgreSQL"), dbname="gis2")
#### order columns required for bicycleStatus function:
# library(jsonlite)
# d <- data.frame(fromJSON('/home/tim/github/cycle-map-stats/Rscript/summary.json',flatten=T))
# d2 <- d[,c(5,7:8,10:17)]
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

## test 
# proposed_NCN




#### May make a function to call data from db into R pacakge?  

# bicycleData <- function(user=user,
#                         password=password, dbname=dbname, host=host){
#   
#   library(RODBC)
#   library(RPostgreSQL)
#   
#   con <- dbConnect(dbDriver("PostgreSQL"), user=user,
#                    password=password, dbname=dbname, host=host)

##### drop all tables if exists
dbSendQuery(con, paste("DROP TABLE IF EXISTS shop_scotland_area, bicycle_parking, bicycle, shop_scotland_poly, shops, shops_point"))

# dbSendQuery(con, paste("DROP TABLE IF EXISTS bicycle_parking, bicycle"))

# dbSendQuery(con, paste("DROP TABLE IF EXISTS bicycle_parking"))
##### create table of cycle parking from OSM - can be points, area or lines:
dbSendQuery(con,paste("create table bicycle_parking
as 
select  p.covered, p.way, p.osm_id, p.osm_timestamp, p.osm_version, p.osm_uid, p.tags->'capacity' capacity
from planet_osm_point p
where p.amenity = 'bicycle_parking'
union all 
select  covered, way, osm_id, osm_timestamp, osm_version, osm_uid, tags->'capacity' capacity
from planet_osm_line
where planet_osm_line.amenity = 'bicycle_parking'
union all 
select  covered, way, osm_id, osm_timestamp, osm_version,osm_uid, tags->'capacity' capacity
from planet_osm_polygon
where planet_osm_polygon.amenity = 'bicycle_parking'"))

dbSendQuery(con,paste("update bicycle_parking set way = ST_Centroid(way)"))           
 dbSendQuery(con,paste("ALTER TABLE bicycle_parking ADD COLUMN cap NUMERIC"))      

#  
#  CREATE TABLE osm_hetero(gid serial NOT NULL,
#                          osm_id integer, geom geometry,
#                          ar_num integer, tags hstore,
#                          CONSTRAINT osm_hetero_pk PRIMARY KEY (gid),
#                          CONSTRAINT enforce_dims_geom CHECK (st_ndims(geom) = 2),
#                          CONSTRAINT enforce_srid_geom CHECK (st_srid(geom) = 4326));
#  
 INSERT INTO osm_hetero(osm_id, geom, ar_num, tags)
 SELECT o.osm_id, ST_Intersection(o.geom, a.geom) As geom,
 a.ar_num, o.tags
 FROM
 (SELECT osm_id, ST_Transform(way, 4326) As geom, tags FROM
 planet_osm_line) AS O INNER JOIN merged AS A ON
 (ST_Intersects(o.geom, a.geom));
 
 CREATE INDEX idx_osm_hetero_geom
 ON osm_hetero USING gist(geom);
 CREATE INDEX idx_osm_hetero_tags
 ON osm_hetero USING gist(tags);
 VACUMM ANALYZE osm_hetero;
 
#### Areas update ####

  ### Just some queries I've used in testing, handy for reference:
  # ALTER TABLE merged ADD COLUMN tags hstore
 #ALTER TABLE merged ADD COLUMN osm_id integer
# dbSendQuery(con,paste("ALTER TABLE merged ADD COLUMN version NUMERIC"))
# dbSendQuery(con,paste("update merged SET commuting_by_bicycle = 42 WHERE commuting_by_bicycle IS NULL"))
# dbSendQuery(con,paste("update merged SET commuting_by_bicycle = CAST (census.bikers as NUMERIC) FROM census WHERE census.name = merged.name"))
# dbSendQuery(con,paste("ALTER TABLE merged ADD COLUMN commuting_by_bicycle NUMERIC"))
# dbSendQuery(con,paste("update merged SET code = 0 WHERE code IS NULL"))
# dbSendQuery(con,paste("UPDATE merged SET name = 'Stadsregio Amsterdam' WHERE name = ''"))
# dbGetQuery(con,paste("update merged SET name = area10.name FROM area10 WHERE area10.code = merged.code"))
# dbGetQuery(con,paste("update merged set name = left(name, -8)"))
#dbSendQuery(con,paste("alter table merged ADD column proposed_highways NUMERIC"))
#dbSendQuery(con,paste("alter table merged ADD column construction_highways NUMERIC"))
#dbSendQuery(con,paste("alter table merged drop column edit_date"))
# dbSendQuery(con,paste("alter table merged add column edit_date DATE"))
# dbSendQuery(con,paste("ALTER TABLE merged ADD COLUMN editors NUMERIC"))
# dbSendQuery(con,paste("ALTER TABLE merged ADD COLUMN proposed_off_road_cycleway NUMERIC"))
# dbSendQuery(con,paste("ALTER TABLE merged ADD COLUMN construction_off_road_cycleway NUMERIC"))
# dbSendQuery(con,paste("ALTER TABLE merged ADD COLUMN proposed_NCN NUMERIC"))
# dbSendQuery(con,paste("ALTER TABLE merged ADD COLUMN off_road_cycleway NUMERIC"))
# dbSendQuery(con,paste("ALTER TABLE merged ADD COLUMN highways NUMERIC"))
# dbSendQuery(con,paste("ALTER TABLE merged ADD COLUMN NCN NUMERIC"))
# dbSendQuery(con,paste("ALTER TABLE merged ADD COLUMN cycleway_v_highway NUMERIC"))
# dbSendQuery(con,paste("ALTER TABLE merged ADD COLUMN bicycle_parking INTEGER"))
# dbSendQuery(con,paste("ALTER TABLE merged ADD COLUMN area NUMERIC"))

######### Polygon file called 'merged' contains the areas of interest i.e. a
######### postgis table on your database of the areas you are interested to
######### query

#### Here follows are series of queries for getting summary data for each multipolygon area:
# highway proposed
dbSendQuery(con,paste("UPDATE merged SET proposed_h = (
SELECT   sum(ST_Length(ST_intersection(ST_Transform(r.way,4326)::geography,ST_Transform(merged.way,4326)::geography))/1000)
  FROM planet_osm_line r
  WHERE ST_Intersects(merged.way, r.way) AND r.highway = 'proposed'
AND not r.tags->'proposed' in ('cycleway','bridleway','bicycle','footway','raceway',
'steps','path','track','pedestrian'))"))

dbSendQuery(con,paste("UPDATE merged SET proposed_h = 0 WHERE proposed_h IS NULL"))


# highway construction
dbSendQuery(con,paste("UPDATE merged SET constructi = (
SELECT   sum(ST_Length(ST_intersection(ST_Transform(r.way,4326)::geography,ST_Transform(merged.way,4326)::geography))/1000)
  FROM planet_osm_line r
  WHERE ST_Intersects(merged.way, r.way)
  AND r.construction is not null 
AND 
r.highway = 'construction' and not r.tags->'construction' in ('cycleway','bridleway','bicycle','footway','raceway',
'steps','path','track','pedestrian'))"))

dbSendQuery(con,paste("UPDATE merged SET constructi = 0 WHERE constructi IS NULL"))

# edit_date
dbSendQuery(con,paste("UPDATE merged SET edit_date = (SELECT 
                        max(osm_timestamp)
FROM 
  bicycle_parking r
WHERE ST_Contains(merged.way,r.way)
)"))

# editors
dbSendQuery(con,paste("UPDATE merged SET editors = (SELECT count(distinct osm_uid)
FROM 
  bicycle_parking r
WHERE ST_Contains(merged.way,r.way)
)"))

# bicycle parking version number
dbSendQuery(con,paste("UPDATE merged SET version = (SELECT 
          sum(osm_version) / count(osm_version)
FROM 
  bicycle_parking r
WHERE ST_Contains(merged.way,r.way)
)"))


dbSendQuery(con,paste("UPDATE merged SET editors = 0 WHERE editors IS NULL"))


# proposed_off_road_cycleway
dbSendQuery(con,paste("UPDATE merged SET proposed_o = (SELECT 
                          sum(ST_Length(ST_intersection(ST_Transform(r.way,4326)::geography,ST_Transform(merged.way,4326)::geography))/1000)
  FROM planet_osm_line r
  WHERE ST_Intersects(merged.way, r.way)
  AND 
(r.highway = 'proposed' and r.tags->'proposed'='cycleway' 
OR (r.highway='proposed' and r.tags->'proposed'='bridleway' 
OR (r.highway = 'proposed' AND r.tags->'bicycle' IN ('yes','designated')))
))"))

dbSendQuery(con,paste("UPDATE merged SET proposed_o = 0 WHERE proposed_o IS NULL"))


# construction_off_road_cycleway
dbSendQuery(con,paste("UPDATE merged SET construc_1 = (SELECT 
                         sum(ST_Length(ST_intersection(ST_Transform(r.way,4326)::geography,ST_Transform(merged.way,4326)::geography))/1000)
  FROM planet_osm_line r
  WHERE ST_Intersects(merged.way, r.way)
  AND 
(r.highway = 'construction' and r.tags->'construction'='cycleway' 
OR (r.highway='construction' and r.tags->'construction'='bridleway' 
OR (r.highway = 'construction' AND r.tags->'bicycle' IN ('yes','designated')))
))"))

dbSendQuery(con,paste("UPDATE merged SET construc_1 = 0 WHERE construc_1 IS NULL"))

# proposed_NCN
dbSendQuery(con,paste("UPDATE merged SET proposed_n = (SELECT 
                         sum(ST_Length(ST_intersection(ST_Transform(r.way,4326)::geography,ST_Transform(merged.way,4326)::geography))/1000)
  FROM planet_osm_line r
  WHERE ST_Intersects(merged.way, r.way)
AND ncn = 'yes' AND r.tags->'state'='proposed')"))

dbSendQuery(con,paste("UPDATE merged SET proposed_n = 0 WHERE proposed_n IS NULL"))

dbSendQuery(con, paste("UPDATE merged SET NCN = (SELECT

 sum(ST_Length(ST_intersection(ST_Transform(r.way,4326)::geography,ST_Transform(merged.way,4326)::geography))/1000)
  FROM planet_osm_line r
  WHERE ST_Intersects(merged.way, r.way)
  AND r.ncn = 'yes'
 )
"))
  

dbSendQuery(con,paste("UPDATE merged SET NCN = 0 WHERE NCN IS NULL"))

# Area
dbSendQuery(con,paste("UPDATE merged SET area = (SELECT ST_Area(ST_Transform(merged.way,4326)::geography) / 10000
                           )"))

# bicycle parking
# get median bicycle capacity value
  
bicycle<-  dbGetQuery(con,paste("SELECT *
                                     FROM bicycle_parking
                                                 "))


bicycle$capacity <- as.numeric(capacityValues$capacity)
bicycleMedian <- median(bicycle$capacity, na.rm=T)

bicycle$capacity[is.na(capacityValues$capacity)] <- bicycleMedian
dbWriteTable(conn=con,  name = 'bicycle', value=bicycle, overwrite=T)
dbSendQuery(con,paste("update bicycle_parking SET cap = CAST (bicycle.capacity as NUMERIC) FROM bicycle WHERE bicycle.osm_id = bicycle_parking.osm_id"))

dbSendQuery(con,paste("update bicycle_parking SET capacity = CAST (capacity as NUMERIC)"))

dbSendQuery(con,paste("UPDATE merged SET bicycle_pa = (SELECT sum(cap)    
                                     FROM bicycle_parking
                            WHERE ST_Intersects(bicycle_parking.way,merged.way)
                         )"))

dbSendQuery(con,paste("UPDATE merged SET bicycle_pa = 0 WHERE bicycle_pa IS NULL"))

# off_road_cycle_paths
 dbSendQuery(con,paste("UPDATE merged SET off_road_c = (SELECT  
  sum(ST_Length(ST_Intersection(ST_Transform(r.way,4326)::geography,ST_Transform(merged.way,4326)::geography))/1000)
  FROM planet_osm_line r
  WHERE ST_Intersects(merged.way, r.way) AND 
(r.highway = 'cycleway' AND r.surface NOT IN ('unpaved','gravel','dirt','grass','mud','earth','fine_gravel','ground','pebblestone','salt','sand','snow','woodchips')
OR (r.highway='bridleway' AND r.surface NOT IN ('unpaved','gravel','dirt','grass','mud','earth','fine_gravel','ground','pebblestone','salt','sand','snow','woodchips') OR (r.highway = 'path' AND r.bicycle in ('yes','designated') AND r.surface 
NOT IN ('unpaved','gravel','dirt','grass','mud','earth','fine_gravel','ground','pebblestone','salt','sand','snow','woodchips')
OR (r.highway='pedestrian' AND r.bicycle in ('yes','designated') OR (r.highway='cycleway' and r.surface IS NULL)
)))))
",sep=""))

dbSendQuery(con,paste("UPDATE merged SET off_road_c = 0 WHERE off_road_c IS NULL"))

# road highways
# dbGetQuery(con,paste("UPDATE merged SET highways = ( SELECT
#  sum(ST_Length(ST_intersection(ST_Transform(r.way,4326)::geography,ST_Transform(merged.way,4326)::geography))/1000)
#   FROM planet_osm_line r
#   WHERE ST_Intersects(r.way,merged.way) AND r.highway is not null AND
# NOT r.highway = 'track' AND NOT r.highway = 'cycleway' AND
# NOT r.highway = 'path' AND NOT r.highway = 'bridleway' AND 
# NOT r.highway = 'footway' AND NOT r.highway = 'steps' AND
# NOT r.highway = 'raceway' AND NOT r.highway = 'pedestrian') WHERE merged.code = 'Seville'"))


# all road/paved vehicle roads excludiong service roads because they are not consistently mapped:
  dbGetQuery(con,paste("UPDATE merged SET highways = ( SELECT
 sum(ST_Length(ST_Transform(r.way,4326)::geography))/1000
  FROM planet_osm_line r
  WHERE ST_Contains(merged.way,r.way) AND r.highway is not null AND
NOT r.highway = 'track' AND NOT r.highway = 'cycleway' AND
NOT r.highway = 'path' AND NOT r.highway = 'bridleway' AND 
NOT r.highway = 'footway' AND NOT r.highway = 'steps' AND
NOT r.highway = 'raceway' AND NOT r.highway = 'pedestrian' AND
NOT r.highway = 'service')"))
  
dbSendQuery(con,paste("UPDATE merged SET highways = 0 WHERE highways IS NULL"))

## save file query outputs into R package as demo data:
### splits into three files - Parliamentary areas, council area and all areas -
### not quite sure the best approach - could just be a single file
system(paste("rm /home/tim/github/mypackage/examples/shiny-examples/bikrApp/scotlandAmsterdam.json"))      
command <- paste("ogr2ogr -f geoJSON /home/tim/github/mypackage/examples/shiny-examples/bikrApp/scotlandAmsterdam.json PG:\"host=localhost dbname=gis2 user=tim password=",password," port=5432\"  merged -lco COORDINATE_PRECISION=4 -simplify 61 -nlt MULTIPOLYGON -s_srs EPSG:900913 -t_srs EPSG:4326",sep="")
system(command)

system(paste("rm /home/tim/github/mypackage/examples/shiny-examples/bikrApp/scotlandMsp.json"))  
command <- paste("ogr2ogr -f geoJSON /home/tim/github/mypackage/examples/shiny-examples/bikrApp/scotlandMsp.json PG:\"host=localhost dbname=gis2 user=tim password=",password," port=5432\"  merged -lco COORDINATE_PRECISION=4 -simplify 61 -nlt MULTIPOLYGON -s_srs EPSG:900913 -t_srs EPSG:4326 -where \"area_code IN ('COU','CIT')\" ",sep="")
system(command)

system(paste("rm /home/tim/github/mypackage/examples/shiny-examples/bikrApp/scotlandCouncil.json"))  
command <- paste("ogr2ogr -f geoJSON /home/tim/github/mypackage/examples/shiny-examples/bikrApp/scotlandCouncil.json PG:\"host=localhost dbname=gis2 user=tim password=",password," port=5432\"  merged -lco COORDINATE_PRECISION=4 -simplify 61 -nlt MULTIPOLYGON -s_srs EPSG:900913 -t_srs EPSG:4326 -where \"area_code IN ('UTA','CIT')\" ",sep="")
system(command)
# save RData object into package
library(jsonlite)
d <- data.frame(jsonlite::fromJSON('/home/tim/github/mypackage/examples/shiny-examples/bikrApp/scotlandAmsterdam.json',flatten=T))
system(paste("rm /home/tim/github/mypackage/examples/shiny-examples/bikrApp/scotlandAmsterdam.json"))  
scotlandMsp <- d[d$features.properties.area_code == "COU" | d$features.properties.area_code == "CIT",c(5:6,7:21),]
scotlandCouncil <- d[d$features.properties.area_code  == "UTA" | d$features.properties.area_code  == "CIT",c(5:6,7:21),]
d2 <- d[d$features.properties.area_code  == "UTA" | d$features.properties.area_code  == "CIT" | d$features.properties.area_code  == "COU",c(5:6,7:21),]
names(scotlandMsp) <- c("code","name", "cyclepath", "road", "bicycleparking","area","routes","proposedroutes", "proposedcyclepath", "constructionroad", "editors", "lasteditdate", "proposedroad", "constructioncyclepath","commutingbybicycle","version","areacode")
names(scotlandCouncil) <- c("code","name", "cyclepath", "road", "bicycleparking","area","routes","proposedroutes", "proposedcyclepath", "constructionroad", "editors", "lasteditdate", "proposedroad", "constructioncyclepath","commutingbybicycle","version","areacode")
names(d2) <- c("code","name", "cyclepath", "road", "bicycleparking","area","routes","proposedroutes", "proposedcyclepath", "constructionroad", "editors", "lasteditdate", "proposedroad", "constructioncyclepath","commutingbybicycle","version","areacode")
scotlandAmsterdam <- d2
save(scotlandMsp,file="data/scotlandMsp.RData",compress='xz') 
save(scotlandCouncil,file="data/scotlandCouncil.RData",compress='xz') 
save(scotlandAmsterdam,file="data/scotlandAmsterdam.RData",compress='xz') 


library(bikr)
library(RJSONIO)

d1 <- bicycleStatus(scotlandMsp)
d1$fillcolor <- ifelse(d1$Status == "High","#ffffb2","")
d1$fillcolor <- ifelse(d1$Status == "Good","#fecc5c",d1$fillcolor)
d1$fillcolor <- ifelse(d1$Status == "Moderate","#fd8d3c",d1$fillcolor)
d1$fillcolor <- ifelse(d1$Status == "Poor","#f03b20",d1$fillcolor)
d1$fillcolor <- ifelse(d1$Status == "Bad","#bd0026",d1$fillcolor)

e1 <- bicycleStatus(scotlandCouncil)
e1$fillcolor <- ifelse(e1$Status == "High","#ffffb2","")
e1$fillcolor <- ifelse(e1$Status == "Good","#fecc5c",e1$fillcolor)
e1$fillcolor <- ifelse(e1$Status == "Moderate","#fd8d3c",e1$fillcolor)
e1$fillcolor <- ifelse(e1$Status == "Poor","#f03b20",e1$fillcolor)
e1$fillcolor <- ifelse(e1$Status == "Bad","#bd0026",e1$fillcolor)

f <- '~/Documents/github/R/bikr/examples/shiny-examples/bikrApp/scotlandMsp.json'
con = file(f,"r")
geojson <- RJSONIO::fromJSON('~/Documents/github/bikr/examples/shiny-examples/bikrApp/scotlandMsp.json')
geojson <- RJSONIO::fromJSON('~/Documents/github/bikr/examples/shiny-examples/bikrApp/scotlandCouncil.json')

d2 <- RJSONIO::fromJSON('scotlandCouncil.json')
    

d <- e1
for (i in 1:length(d[,1])){
  
  geojson$features[[i]]$properties$style   <-  list(weight = 5, stroke = "true",
                                                    fill = "true", opacity = 0.9,
                                                    fillOpacity = 0.9, color= paste(d$fillcolor[d$name == geojson$features[[i]]$properties$name]),
                                                    fillColor = paste(d$fillcolor[d$name == geojson$features[[i]]$properties$name]))

}
