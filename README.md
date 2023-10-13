[![Project Status: Abandoned – Initial development has started, but there has not yet been a stable, usable release; the project has been abandoned and the author(s) do not intend on continuing development.](https://www.repostatus.org/badges/latest/abandoned.svg)](https://www.repostatus.org/#abandoned)
*The project has been abandoned and the author do not intend on continuing development.*


# R Interface to the Photon API 

Photon is an open source geocoder built for OpenStreetMap data and based on elasticsearch. 
This package allows to query a photon API and get the results in a data frame.

Photon web site: https://photon.komoot.io/    
Photon source code: https://github.com/komoot/photon

## Install Instructions
<pre><code>require(devtools)  
devtools::install_github(repo = 'rCarto/photon')  
</code></pre>

## Usage
### `geocode()`
<pre><code>address <- c("19 rue Michel Bakounine, 29600 Morlaix, France",
             "5 rue Proudhon, 34130 Mauguio France",
             "2 Emma Goldmanweg, Tilburg, Netherlands",
             "36 Strada Panait Israti, Bucarest, Romania")
place <- geocode(address, limit = 1, key = "place")
place
</code></pre>
<small>

|location                                       |osm_id     |osm_type |name |housenumber |street                |postcode |city      |state         |country         |osm_key |osm_value |       lon|      lat|msg |
|:----------------------------------------------|:----------|:--------|:----|:-----------|:---------------------|:--------|:---------|:-------------|:---------------|:-------|:---------|---------:|--------:|:---|
|19 rue Michel Bakounine, 29600 Morlaix, France |3241060871 |N        |NA   |19          |Rue Michel Bakounine  |29600    |Morlaix   |Brittany      |France          |place   |house     | -3.816435| 48.59041|NA  |
|5 rue Proudhon, 34130 Mauguio France           |3700168030 |N        |NA   |5           |Rue Proudhon          |34130    |Mauguio   |Occitania     |France          |place   |house     |  4.008024| 43.61583|NA  |
|2 Emma Goldmanweg, Tilburg, Netherlands        |2844596196 |N        |NA   |2           |Emma Goldmanweg       |5032MN   |Tilburg   |North Brabant |The Netherlands |place   |house     |  5.041361| 51.53783|NA  |
|36 Strada Panait Israti, Bucarest, Romania     |2838254765 |N        |NA   |36          |Strada Panait Istrati |011547   |Bucharest |NA            |Romania         |place   |house     | 26.064266| 44.46227|NA  |

</small>
<pre><code>geocode("Montreuil", limit = 1)</code></pre>
<small>

|location  |osm_id  |osm_type |name      |housenumber |street |postcode |city |state                          |country |osm_key |osm_value |      lon|      lat|msg |
|:---------|:-------|:--------|:---------|:-----------|:------|:--------|:----|:------------------------------|:-------|:-------|:---------|--------:|--------:|:---|
|Montreuil |2622231 |R        |Montreuil |NA          |NA     |62170    |NA   |Nord-Pas-de-Calais and Picardy |France  |place   |village   | 1.764228| 50.46375|NA  |

</small>

<pre><code>geocode("Montreuil", locbias = c(2.4, 48.9), limit = 1)</code></pre>
<small>

|location  |osm_id |osm_type |name      |housenumber |street |postcode |city |state         |country |osm_key |osm_value |      lon|      lat|msg |
|:---------|:------|:--------|:---------|:-----------|:------|:--------|:----|:-------------|:-------|:-------|:---------|--------:|--------:|:---|
|Montreuil |129423 |R        |Montreuil |NA          |NA     |93100    |NA   |Ile-de-France |France  |place   |city      | 2.441218| 48.86234|NA  |

</small>

<pre><code># with a typical local install of photon
place <- geocode(address, limit = 1, key = "place", server = "http://0.0.0.0:2322/")
</code></pre>

### `reverse()`
<pre><code>address <- c("19 rue Michel Bakounine, 29600 Morlaix, France",
             "5 rue Proudhon, 34130 Mauguio France",
             "2 Emma Goldmanweg, Tilburg, Netherlands",
             "36 Strada Panait Israti, Bucarest, Romania")
place <- geocode(address, limit = 1, key = "place")
place2 <- reverse(x = place$lon, y = place$lat)
place2</code></pre>
<small>

|         x|        y|osm_id     |osm_type |name |housenumber |street                |postcode |city      |state         |country         |osm_key |osm_value |       lon|      lat|msg |
|---------:|--------:|:----------|:--------|:----|:-----------|:---------------------|:--------|:---------|:-------------|:---------------|:-------|:---------|---------:|--------:|:---|
| -3.816435| 48.59041|3241060871 |N        |NA   |19          |Rue Michel Bakounine  |29600    |Morlaix   |Brittany      |France          |place   |house     | -3.816435| 48.59041|NA  |
|  4.008024| 43.61583|3700168030 |N        |NA   |5           |Rue Proudhon          |34130    |Mauguio   |Occitania     |France          |place   |house     |  4.008024| 43.61583|NA  |
|  5.041361| 51.53783|2844596196 |N        |NA   |2           |Emma Goldmanweg       |5032MN   |Tilburg   |North Brabant |The Netherlands |place   |house     |  5.041361| 51.53783|NA  |
| 26.064266| 44.46227|2838254765 |N        |NA   |36          |Strada Panait Istrati |011547   |Bucharest |NA            |Romania         |place   |house     | 26.064266| 44.46227|NA  |

</small>
<pre><code>identical(place[,2:12], place2[,3:13])
>TRUE
</code></pre>
