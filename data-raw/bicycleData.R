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

dbSendQuery(con, paste("drop table shop_scotland_area, bicycle_parking, shop_scotland_poly, shops, shops_point"))

##### cycle parking

dbSendQuery(con,paste("create table bicycle_parking as select * from planet_osm_point where planet_osm_point.amenity = 'bicycle_parking'"))

#### amenity/shop points

dbSendQuery(con,paste("create table shop_scotland_area as 
select
planet_osm_point.shop, planet_osm_point.amenity, planet_osm_point.name, planet_osm_point.\"addr:housename\",
planet_osm_point.capacity, ST_Buffer(planet_osm_point.way, 50) as way, planet_osm_point.osm_id
from
 planet_osm_point
where
planet_osm_point.shop IS NOT NULL
OR planet_osm_point.amenity in ('cafe','restaurant','pub')"))


dbSendQuery(con,paste("UPDATE shop_scotland_area SET capacity = (SELECT count(*)
FROM cycle_parking_scotland WHERE ST_Intersects(cycle_parking_scotland.way, shop_scotland_area.way));
                                        "))

##### ways / polygon shops amenities #####

# dbSendQuery(con, paste("drop table shop_scotland_poly"))


dbSendQuery(con,paste("create table shop_scotland_poly as 
select
planet_osm_polygon.shop, planet_osm_polygon.amenity, planet_osm_polygon.name, planet_osm_polygon.\"addr:housename\", 
planet_osm_polygon.osm_version  as capacity, ST_Buffer(planet_osm_polygon.way,30) as way, planet_osm_polygon.osm_id
from
 planet_osm_polygon
where
planet_osm_polygon.shop IS NOT NULL
OR planet_osm_polygon.amenity in ('cafe','restaurant','pub')"))

dbSendQuery(con,paste("UPDATE shop_scotland_poly SET capacity = (SELECT count(*)
FROM cycle_parking_scotland WHERE ST_Intersects(cycle_parking_scotland.way, shop_scotland_poly.way));
                                        "))
### union area and polygon shops ####

dbSendQuery(con,paste("create table shops as select shop, amenity,name, \"addr:housename\", capacity, way, osm_id
from shop_scotland_poly
      union all 
select shop, amenity, name, \"addr:housename\", capacity, way, osm_id 
    from shop_scotland_area"))

# dbSendQuery(con, paste("drop table shops_point"))
dbSendQuery(con,paste("create table shops_point as select shop, amenity,name, \"addr:housename\", 
capacity, ST_Centroid(way) as way, osm_id
from shops"))

dbSendQuery(con,paste("ALTER table shops_point ALTER COLUMN way TYPE geometry(Point, 4326) 
USING ST_Transform(ST_SetSRID(shops_point.way,900913), 4326)"))

#### export and sace to dropbox ####
 
  system(paste("rm /home/tim/Dropbox/Public/cyclemap/shops.json"))      
 command <- paste("ogr2ogr -f GeoJSON /home/tim/Dropbox/Public/cyclemap/shops.json PG:\"host=localhost dbname=gis2 user=tim password=gladstone port=5432\"  shops_point -lco COORDINATE_PRECISION=4",sep="")
system(command)

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


# dbSendQuery(con,paste("UPDATE merged SET edit_date = 0 WHERE edit_date IS NULL"))

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
