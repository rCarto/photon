#' @title Geocode Locations With Photon API
#' @name photon
#' @description Photon is an open source geocoder built for OpenStreetMap data
#' and based on elasticsearch. This package allows to query a photon API and get
#' the results in a data frame.
#' @docType package
NULL



#' @title Geocode Locations With Photon API
#' @name geocode
#' @description This function geocode locations using the photon API.
#' @param location Location(s) to geocode, a character vector.
#' @param limit Maximum number of returned results.
#' @param key Photon allows filtering based on OSM tags and values (see photon
#' documentation).
#' @param value Photon allows filtering based on OSM tags and values (see photon
#' documentation).
#' @param lang Photon is multilingual, this parameter allows to specify a
#' language.
#' @param server Select which API is used. The default API is the photon public
#' API (see Details), but you can use your own photon API.
#' @param quiet Should the function print the currently processed input ?
#' @details Terms of use of the photon public API: \cr
#' "You can use the API for your
#' project, but please be fair - extensive usage will be throttled. We do not
#' guarantee for the availability and usage might be subject of change in the
#' future. Have fun with photon and make OSM grow!"
#' @return A data.frame with the following fields is returned :\cr
#' location, name, housenumber, street, postcode, city, state, country, osm_key,
#' osm_value,  lon,  lat, msg.\cr
#' \code{location} is the original searched location.\cr
#' \code{lon} and \code{lat} are longitude and latitude (WGS84).\cr
#' \code{msg} is filled with the "Not found" text string if no results are found for a
#' location.
#' @import RCurl
#' @import RJSONIO
#' @references
#' Photon web site \url{http://photon.komoot.de/}\cr
#' Photon source code \url{https://github.com/komoot/photon}
#' @examples
#' loc <- c("19 rue Michel Bakounine, 29600 Morlaix, France",
#'          "5 rue Proudhon, 34000 Montpellier, France",
#'          "2 Emma Goldmanweg, Tilburg, Netherlands",
#'          "36 Strada Panait Istrati, Bucarest, Romania")
#' geocode(loc, limit = 1, key = "place")
#' @export
geocode <- function(location, limit = NULL, key = NULL, value = NULL,
                    lang = NULL,
                    server = NULL, quiet = FALSE){
  # options management
  if (!is.null(limit)){limit <- paste("&limit=",limit, sep="") }
  if (!is.null(key)){key <- paste("&osm_tag=",key, sep="")}
  if (!is.null(value)){
    if (!is.null(key)) {
      value <- paste(":",value, sep="")
    }else{
      value <- paste("&osm_tag=:",value, sep="")
    }
  }
  if (!is.null(lang)){lang <- paste("&lang=",lang, sep="")}
  params <- paste(limit, key, value, lang, sep = "")
  if (is.null(server)){server <- "http://photon.komoot.de/"}

  # result data.frame
  pts <- data.frame(location = character(0),
                    name = character(0), housenumber = character(0),
                    street = character(0),
                    postcode = character(0), city = character(0),
                    state = character(0),
                    country = character(0), osm_key = character(0),
                    osm_value = character(0), lon = numeric(0),
                    lat = numeric(0),
                    msg = character(0),
                    stringsAsFactors = FALSE)


  # query builder
  llocation <- length(location)
  for (i in 1:llocation){
    # buid query
    if (!quiet){
      print(location[i])
    }
    searched <- paste(server,"api?q=",location[i], params, sep="")
    x <- tryCatch(
      {
        curl = getCurlHandle()
        # send query
        RCurl::getURL(URLencode(searched), curl = curl)
      },
      error = function(condition){
        cat(getCurlInfo(curl, "response.code")[[1]])
      }
    )

    # parse result
    ret <- RJSONIO::fromJSON(x)
    nbfeat <- length(ret$features)
    # if result...
    if(nbfeat > 0){
      for (j in 1:nbfeat){
        ret_names <- intersect(names(pts),
                               names(ret$features[[j]]$properties))
        tmp_df <- data.frame(t(sapply(ret_names, function(x) { ret$features[[j]]$properties[[x]] })),
                             stringsAsFactors=FALSE)
        tmp_df$lon <- ret$features[[j]]$geometry$coordinates[1]
        tmp_df$lat <- ret$features[[j]]$geometry$coordinates[2]
        pts[nrow(pts)+1,c("location",names(tmp_df))] <- c(location[i],
                                                          tmp_df[1,])
      }
    } else {
      pts[nrow(pts)+1,c("location", "msg")] <- c(location[i],"Not found")
    }
  }
  return(pts)
}
