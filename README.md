# bikr

[![Build Status](https://travis-ci.org/fozy81/bikr.svg?branch=master)](https://travis-ci.org/fozy81/bikr)

The main purpose of the bikr package is to create a objective way to rate the quality of bicycle infrastructure in a given area by comparing to the high standard of bicycle provision found in the Amsterdam region.

Currently, the package rates cycle paths, national cycle routes and bicycle parking provision as three key indicators of bicycle infrastructure. Cycle path fragmentation, cycle lanes and quiet street ratings are for future development.

The primary data source is [OpenStreetMap](http://www.openstreetmap.org/#map=9/55.8699/-3.3014&layers=C) data although it is conceivable other sources could be used.

## How do use:

### Website

Check out the [demo website here](https://opendata.shinyapps.io/shinyapp/). This website uses the bikr package and it's functions interactively so you can get a feel for what it can do.

### R package

Download this package into the R environment. You will need to install R and then the package called 'devtools' from CRAN. You can then install the bikr package from github using ``install_github('fozy81/bikr')``. Installing this bikr package will allow you to:

* Read the help documentation and test out how functions work
* Access the demo data that is provided in the package
* Contribute updates back to the project via github 'pull requests' 

There is a great help page [here](http://r-pkgs.had.co.nz/intro.html) for getting started with package development and version control using git. Please get in touch or post an issue if you want to help develop a feature. 

### API

The bikr package is also hosted on Open CPU public server. This allows access to the summary data in csv or json format. For instance:
* (https://public.opencpu.org/ocpu/github/fozy81/bikr/data/scotlandMsp/csv) Scottish Parliament + Europe Cities in CSV
* (https://public.opencpu.org/ocpu/github/fozy81/bikr/data/scotlandCouncil/json) Scottish Council + Europe Cities in JSON
* (https://public.opencpu.org/ocpu/github/fozy81/bikr/data/scotlandAmsterdam/json) All data in JSON.

You can also query the statistical functions in the package over a HTTP API or via a javascript library - which allows embedding of the data or reactively running the functions on any website. Check out the [Open CPU](https://www.opencpu.org/) website for more details.

### Re-create from raw OpenStreetMap data

If you want to assess the bicycle infrastructure for your own custom area - this is a more complex process as you need to run queries against raw OpenStreetMap data which can be a bulky and time consuming process. OpenStreetMap data requires a postgresql database with the postGIS plugin enabled and data added using a command line tool called osm2postgresql. The script for extracting the relevant data is in the data-raw folder but this needs some work to automate - I'm looking into setting up at a Docker container to initialize the Db backend in a few clicks. For now, if you are really interested, then pick through the file in data-raw and piece together what you need to do. Basically, some osm data and some area polygons. Then query the osm data for each area polygon - adding summary stats to the area polygon features. But installing postgresql and other tools may take a while if you have not done it before...

Other command line tools required to complete the process:

* osmosis
* ogr2ogr











