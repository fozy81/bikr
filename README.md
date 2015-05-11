# bikr

[![Build Status](https://travis-ci.org/fozy81/bikr.svg?branch=master)](https://travis-ci.org/fozy81/bikr)

The main purpose of the bikr package is to create a objective way to rate the quality of bicycle infrastructure in a given area by comparing to the high standard of bicycle provision found in the Amsterdam region.

Currently, the package rates cycle paths, national cycle routes and bicycle parking provision as three key indicators of bicycle infrastructure. Cycle path fragmentation, cycle lanes and quiet street ratings are for future development.

Check out a demo here: https://opendata.shinyapps.io/shinyapp/

The primary data source is OpenStreetMap data although it is conceivable other sources could be used.

### How do use

You can use this package in four ways:

1. Click on the link above to view a demo website which uses the bikr package and it's functions interactively to get a feel for what it can do.

2. Download this package into the R environment. You will need to install R and then the package called 'devtools' from CRAN. You can then install the bikr package from github using ``install_github('fozy81/bikr')``. Installing this bikr package will allow you to:

* Read the help documentation and test out how functions work
* Access the demo data that is provided in the package
* Contribute updates back to the project via github 'pull requests' 

There is a great help page [here](http://r-pkgs.had.co.nz/intro.html) for getting started with package development and version control using git. 

3. If you want to create your own data for a particular area - this is more involved. The openstreetmap data requires a postgresql database with the postGIS plugin enabled and data added using a command line tool called osm2postgresql. The script for extracting the relevant data is in the data-raw folder but this needs some work to automate - I'm looking into setting up at a Docker container to initialize the Db backend in a few clicks. For now, if you are really interested, then pick through the file in data-raw and piece together what you need to do. Basically, some osm data and some area polygons. Then query the osm data for each area - adding summary stats to the area features. But installing postgresql and other tools may take a while if you have not done it before...

4. The bikr package is also hosted on Open CPU public server. This allows you to query the functions in the package over a HTTP API or via a javascript library - which allows embedding of the data or reactively running the functions on any website. Check out the [Open CPU](https://www.opencpu.org/) website for more details.











