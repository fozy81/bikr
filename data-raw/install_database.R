

# linux 14.04 LTS


# install required libraries on ubuntu  

# sudo apt-get install libboost-all-dev subversion git-core tar unzip wget bzip2 build-essential autoconf libtool libxml2-dev libgeos-dev libgeos++-dev libpq-dev libbz2-dev libproj-dev munin-node munin libprotobuf-c0-dev protobuf-c-compiler libfreetype6-dev libpng12-dev libtiff4-dev libicu-dev libgdal-dev libcairo-dev libcairomm-1.0-dev apache2 apache2-dev libagg-dev liblua5.2-dev ttf-unifont lua5.1 liblua5.1-dev libgeotiff-epsg node-carto

# postgis:

# sudo apt-get install postgresql postgresql-contrib postgis postgresql-9.3-postgis-2.1

 # sudo -u postgres -i
# createuser username # answer yes for superuser (although this isn't strictly necessary)
#createdb -E UTF8 -O username gis
# exit
# 

install postgres
sudo -u postgres psql
\c gis2
CREATE EXTENSION postgis;
ALTER TABLE geometry_columns OWNER TO tim;
ALTER TABLE spatial_ref_sys OWNER TO tim;
\q
exit
# 
# install postgis extension in gis
# mkdir ~/src
# cd ~/src
# git clone git://github.com/openstreetmap/osm2pgsql.git
# cd osm2pgsql
# ./autogen.sh
# ./configure
# make
# sudo make install



 # sudo apt-get install osmosis
 # sudo apt-get install openjdk-7-jre

##### Need default style sheet loaded from github???

