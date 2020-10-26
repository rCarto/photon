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
#' @param locbias Location bias. A pair of coordinates (WGS84, \code{c(Lon, Lat)})
#' to center the search.
#' @param server Select which API is used. The default API is the photon public
#' API (see Details), but you can use your own photon API.
#' @param quiet Should the function print the currently processed input ?
#' @details Terms of use of the photon public API: \cr
#' "You can use the API for your
#' project, but please be fair - extensive usage will be throttled. We do not
#' guarantee for the availability and usage might be subject of change in the
#' future. Have fun with photon and make OSM grow!"
#' @return A data.frame with the following fields is returned :\cr
#' location, osm_id, osm_type, name, housenumber, street, postcode, city, state,
#' country, osm_key, osm_value,  lon, lat, msg.\cr
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
#' \dontrun{
#' address <- c("19 rue Michel Bakounine, 29600 Morlaix, France",
#'              "5 rue Proudhon, 34130 Mauguio France",
#'              "2 Emma Goldmanweg, Tilburg, Netherlands",
#'              "36 Strada Panait Israti, Bucarest, Romania")
#' place <- geocode(address, limit = 1, key = "place")
#' place
#'
#' geocode("Montreuil", limit = 1)
#' geocode("Montreuil", locbias = c(2.4, 48.9), limit = 1)
#'
#' # with a typical local install of photon
#' place <- geocode(address, limit = 1, key = "place", server = "http://0.0.0.0:2322/")
#' }
#' @export
geocode <- function (location, limit = NULL, key = NULL, value = NULL, 
          lang = NULL, locbias = NULL, server = NULL, quiet = TRUE) 
{
  if (!is.null(limit)) {
    limit <- paste0("&limit=", limit)
  }
  if (!is.null(key)) {
    key <- paste0("&osm_tag=", key)
  }
  if (!is.null(locbias)) {
    locbias <- paste0("&lon=", locbias[1], "&lat=", locbias[2])
  }
  if (!is.null(value)) {
    if (!is.null(key)) {
      value <- paste0(":", value)
    }
    else {
      value <- paste0("&osm_tag=:", value)
    }
  }
  if (!is.null(lang)) {
    lang <- paste0("&lang=", lang)
  }
  params <- paste0(limit, key, value, lang, locbias)
  if (is.null(server)) {
    server <- "https://photon.komoot.io/"
    sleepy <- 1
  }
  else {
    sleepy <- 0
  }
  pts <- data.frame(location = character(0), osm_id = numeric(0), 
                    osm_type = character(0), name = character(0), housenumber = character(0), 
                    street = character(0), postcode = character(0), city = character(0), 
                    state = character(0), country = character(0), osm_key = character(0), 
                    osm_value = character(0), lon = numeric(0), lat = numeric(0), 
                    msg = character(0), stringsAsFactors = FALSE)
  llocation <- length(locations)
  for (i in 1:llocation) {
    searched <- paste0(server, "api?q=", str_replace_all(location[i],"&","and"), params)
    searched <- utils::URLencode(searched)
    if (!quiet) {
      cat(" ", location[i], "\n", searched, "\n")
    }
    x <- tryCatch({
      httr::GET(searched, .encoding = "UTF-8") %>% content(.,as = "text")
    }, error = function(condition) {
      cat(getCurlInfo(curl, "response.code")[[1]])
    })
    ret <- RJSONIO::fromJSON(x, encoding = "UTF-8")
    nbfeat <- length(ret$features)
    if (nbfeat > 0) {
      for (j in 1:nbfeat) {
        ret_names <- intersect(names(pts), names(ret$features[[j]]$properties))
        tmp_df <- data.frame(t(sapply(ret_names, function(x) {
          ret$features[[j]]$properties[[x]]
        })), stringsAsFactors = FALSE)
        tmp_df$lon <- ret$features[[j]]$geometry$coordinates[1]
        tmp_df$lat <- ret$features[[j]]$geometry$coordinates[2]
        pts[nrow(pts) + 1, c("location", names(tmp_df))] <- c(location[i], 
                                                              tmp_df[1, ])
      }
    }
    else {
      pts[nrow(pts) + 1, c("location", "msg")] <- c(location[i], 
                                                    "Not found")
    }
    Sys.sleep(sleepy)
  }
  return(pts)
}




#' @title Reverse Geocode Locations With Photon API
#' @name reverse
#' @description This function reverse geocode locations using the photon API.
#' @param x Longitude(s).
#' @param y Latitude(s).
#' @param server Select which API is used. The default API is the photon public
#' API (see Details), but you can use your own photon API.
#' @details Terms of use of the photon public API: \cr
#' "You can use the API for your
#' project, but please be fair - extensive usage will be throttled. We do not
#' guarantee for the availability and usage might be subject of change in the
#' future. Have fun with photon and make OSM grow!"
#' @return A data.frame with the following fields is returned :\cr
#' x, y, osm_id, osm_type, name, housenumber, street, postcode, city, state,
#' country, osm_key, osm_value,  lon, lat, msg.\cr
#' \code{x} and {y} are the original searched coordinates\cr
#' \code{msg} is filled with the "Not found" text string if no results are found for a
#' location.
#' @import RCurl
#' @import RJSONIO
#' @references
#' Photon web site \url{http://photon.komoot.de/}\cr
#' Photon source code \url{https://github.com/komoot/photon}
#' @examples
#' \dontrun{
#' address <- c("19 rue Michel Bakounine, 29600 Morlaix, France",
#'              "5 rue Proudhon, 34130 Mauguio France",
#'              "2 Emma Goldmanweg, Tilburg, Netherlands",
#'              "36 Strada Panait Israti, Bucarest, Romania")
#' place <- geocode(address, limit = 1, key = "place")
#' place2 <- reverse(x = place$lon, y = place$lat)
#' place2
#'
#' identical(place[,2:12], place2[,3:13])
#' }
#' @export
reverse <- function(x, y, server = NULL){
  # options management
  nloc <- length(x)
  if (is.null(server)){
    server <- "http://photon.komoot.de/"
    sleepy <- 1
  }else{
    sleepy <- 0
  }

  # result data.frame
  pts <- data.frame(
    x = numeric(0),
    y = numeric(0),
    osm_id = numeric(0),
    osm_type = character(0),
    name = character(0),
    housenumber = character(0),
    street = character(0),
    postcode = character(0),
    city = character(0),
    state = character(0),
    country = character(0),
    osm_key = character(0),
    osm_value = character(0),
    lon = numeric(0),
    lat = numeric(0),
    msg = character(0),
    stringsAsFactors = FALSE)

  # reverse(loc$lon, loc$lat)
  # x <- loc$lon[1]
  # y <- loc$lat[1]
  # query builder
  for (i in 1:nloc){
    # buid query
    searched <- paste0(server,"reverse?lon=",x[i],"&lat=",y[i])
    searched <- utils::URLencode(searched)

    resRaw <- tryCatch(
      {
        curl = RCurl::getCurlHandle()
        # send query
        RCurl::getURL(searched, curl = curl, .encoding = "UTF-8")
      },
      error = function(condition){
        cat(getCurlInfo(curl, "response.code")[[1]])
      }
    )

    # parse result
    ret <- RJSONIO::fromJSON(resRaw, encoding = "UTF-8")
    nbfeat <- length(ret$features)
    # if result...
    if(nbfeat > 0){
      for (j in 1:nbfeat){
        ret_names <- intersect(names(pts),
                               names(ret$features[[j]]$properties))
        tmp_df <- data.frame(t(sapply(ret_names, function(x) {ret$features[[j]]$properties[[x]]})),
                             stringsAsFactors=FALSE)
        tmp_df$lon <- ret$features[[j]]$geometry$coordinates[1]
        tmp_df$lat <- ret$features[[j]]$geometry$coordinates[2]
        pts[nrow(pts)+1,names(tmp_df)] <- tmp_df[1,]
        pts[nrow(pts),c("x", "y")] <- c(x[i],y[i])
      }
    } else {
      pts[nrow(pts)+1,c("x", "y", "msg")] <- c(x[i],y[i],"Not found")
    }
    Sys.sleep(sleepy)
  }
  return(pts)
}
