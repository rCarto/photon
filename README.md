# photon
R Interface to the Photon API / Interface entre R et l'API de photon  

Photon is an open source geocoder built for OpenStreetMap data and based on elasticsearch. 
This package allows to query a photon API and get the results in a data frame.

Photon web site: http://photon.komoot.de/     
Photon source code: https://github.com/komoot/photon

## Install Instructions
<code><pre>require(devtools)  
devtools::install_github(repo = 'rCarto/photon')  
</pre></code>

## Usage
<code><pre>loc <- c("19 rue Michel Bakounine, 29600 Morlaix, France",
         "5 rue Proudhon, 34000 Montpellier, France",
         "2 Emma Goldmanweg, Tilburg, Netherlands",
         "36 Strada Panait Israti, Bucarest, Romania")
geocode(loc, limit = 1, key = "place")</pre></code>
