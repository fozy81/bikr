#' Query bicycle data from a database which uses the osm2postgresql schema with all tags h-store activated. 
#' 
#' requires OGR2OGR command line tool and access to osm2postgesql database schema
#' @usage bicycleStatus(user=user, password=password, dbname=dbname, host=host)
#' @param user postgres user name
#' @param password postres password 
#' @param dbname potsgres database name
#' @param host 'localhost' or port



#### database details

#dbname <- "gis2"
#user <- "tim"
#password <- scan("/home/tim/Documents/key/Untitled Document 1.pgpass", what="")
#host <- "localhost"
#con <- dbConnect(dbDriver("PostgreSQL"), user=user,
 #                password=password, dbname=dbname, host=host)


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



#### function

bicycleData <- function(user=user,
                        password=password, dbname=dbname, host=host){
  
  
  library(RPostgreSQL)
  
  con <- dbConnect(dbDriver("PostgreSQL"), user=user,
                   password=password, dbname=dbname, host=host)

######## drop all tables

dbSendQuery(con, paste("DROP TABLE IF EXISTS table bicycle_parking"))

##### cycle parking

dbSendQuery(con,paste("create table bicycle_parking as select * from planet_osm_point where planet_osm_point.amenity = 'bicycle_parking'"))

#### Areas update ####

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

dbSendQuery(con,paste("UPDATE merged SET editors = 0 WHERE editors IS NULL"))


# proposed_off_road_cycleway

dbSendQuery(con,paste("UPDATE merged SET proposed_off_road_cycleway = (SELECT 
                         sum(ST_Length(ST_Transform(r.way,4326)::geography))/1000 
FROM 
  planet_osm_line r
WHERE ST_Contains(merged.way,r.way) AND 
(r.highway = 'proposed' and r.tags->'proposed'='cycleway' 
OR (r.highway='proposed' and r.tags->'proposed'='bridleway' 
OR (r.highway = 'proposed' AND r.tags->'bicycle' IN ('yes','designated')))
))"))

dbSendQuery(con,paste("UPDATE merged SET proposed_off_road_cycleway = 0 WHERE proposed_off_road_cycleway IS NULL"))


# construction_off_road_cycleway

dbSendQuery(con,paste("UPDATE merged SET construction_off_road_cycleway = (SELECT 
                         sum(ST_Length(ST_Transform(r.way,4326)::geography))/1000 
FROM 
  planet_osm_line r
WHERE ST_Contains(merged.way,r.way) AND 
(r.highway = 'construction' and r.tags->'construction'='cycleway' 
OR (r.highway='construction' and r.tags->'construction'='bridleway' 
OR (r.highway = 'construciton' AND r.tags->'bicycle' IN ('yes','designated')))
))"))

dbSendQuery(con,paste("UPDATE merged SET construction_off_road_cycleway = 0 WHERE construction_off_road_cycleway IS NULL"))

# proposed_NCN

dbSendQuery(con,paste("UPDATE merged SET proposed_NCN = (SELECT 
                         sum(ST_Length(ST_Transform(r.way,4326)::geography))/1000 
FROM 
  planet_osm_line r
WHERE ST_Contains(merged.way,r.way) AND ncn = 'yes' AND r.tags->'state'='proposed')"))

dbSendQuery(con,paste("UPDATE merged SET proposed_NCN = 0 WHERE proposed_NCN IS NULL"))

# NCN length

dbSendQuery(con,paste("UPDATE merged SET NCN = (SELECT 
                         sum(ST_Length(ST_Transform(r.way,4326)::geography))/1000 
FROM 
  planet_osm_line r
WHERE ST_Contains(merged.way,r.way) AND ncn = 'yes'  )"))

dbSendQuery(con,paste("UPDATE merged SET NCN = 0 WHERE NCN IS NULL"))

# Area

dbSendQuery(con,paste("UPDATE merged SET area = (SELECT ST_Area(ST_Transform(merged.way,4326)::geography) / 10000
                           )"))

# bicycle parking

dbSendQuery(con,paste("UPDATE merged SET bicycle_parking = (SELECT count(amenity)    
                                     FROM bicycle_parking
                            WHERE ST_Intersects(bicycle_parking.way,merged.way)
                         )"))

dbSendQuery(con,paste("UPDATE merged SET bicycle_parking = 0 WHERE bicycle_parking IS NULL"))

# off_road_cycle_paths

 dbSendQuery(con,paste("UPDATE merged SET off_road_cycleway = (SELECT  
 sum(ST_Length(ST_Transform(r.way,4326)::geography))/1000 
FROM 
  planet_osm_line r
WHERE ST_Contains(merged.way,r.way) AND 
(r.highway = 'cycleway' OR (r.highway='bridleway' OR (r.highway = 'path' AND r.bicycle in ('yes','designated')))
))
",sep=""))

dbSendQuery(con,paste("UPDATE merged SET off_road_cycleway = 0 WHERE off_road_cycleway IS NULL"))

# road highways

dbSendQuery(con,paste("UPDATE merged SET highways = (
SELECT  sum(ST_Length(ST_Transform(r.way,4326)::geography))/1000
FROM
planet_osm_line r
WHERE
ST_Contains(merged.way,r.way) AND
NOT r.highway = 'track' AND NOT r.highway = 'cycleway' AND
NOT r.highway = 'path' AND NOT r.highway = 'bridleway' AND 
NOT r.highway = 'footway' AND NOT highway = 'steps' AND
NOT r.highway = 'raceway' AND NOT r.highway = 'pedestrian')"))

dbSendQuery(con,paste("UPDATE merged SET highways = 0 WHERE highways IS NULL"))

# ratio

dbSendQuery(con,paste("UPDATE merged SET cycleway_v_highway = 
off_road_cycleway/merged.highways
"))

dbSendQuery(con,paste("UPDATE merged SET cycleway_v_highway = 0 WHERE cycleway_v_highway IS NULL"))


system(paste("rm /home/tim/github/cycle-map-stats/Rscript/summary.json"))      
command <- paste("ogr2ogr -f geoJSON /home/tim/github/cycle-map-stats/Rscript/summary.json PG:\"host=localhost dbname=gis2 user=tim password=",password," port=5432\"  merged -lco COORDINATE_PRECISION=4 -simplify 50 -nlt MULTIPOLYGON -s_srs EPSG:900913 -t_srs EPSG:4326",sep="")
#command2 <- paste("topojson -o /home/tim/github/cycle-map-stats/Rscript/summaryTopo.json /home/tim/github/cycle-map-stats/Rscript/summary.json")
system(command)
#system(command2)

}
