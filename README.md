# R Interface to the Photon API 

Photon is an open source geocoder built for OpenStreetMap data and based on elasticsearch. 
This package allows to query a photon API and get the results in a data frame.

Photon web site: http://photon.komoot.de/     
Photon source code: https://github.com/komoot/photon

## Install Instructions
<pre><code>require(devtools)  
devtools::install_github(repo = 'rCarto/photon')  
</code></pre>

## Usage
<pre><code>loc <- c("19 rue Michel Bakounine, 29600 Morlaix, France",
         "5 rue Proudhon, 34000 Montpellier, France",
         "2 Emma Goldmanweg, Tilburg, Netherlands",
         "36 Strada Panait Israti, Bucarest, Romania")
geocode(loc, limit = 1, key = "place")</code></pre>
