library(leaflet)
library(tidyverse)
leaflet() %>% addTiles() %>%  addPolygons(data = chl,fillColor = topo.colors(10, alpha = NULL), stroke = FALSE)

topoData <- readLines("comunas.json") %>% paste(collapse = "\n")

leaflet() %>%
  setView(-70.1404253,-38.1671819,zoom=5) %>% 
  addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
           attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
  addTopoJSON(topoData, weight = 1, color = "#444444", fillColor = "#E78181",fillOpacity=0.2)

chl <- readOGR(dsn="comunas.json",encoding = "UTF-8")
geoID <- as.vector(chl$id)
geoNAME <- as.vector(chl$name)

leaflet(chl) %>%
  setView(-70.1404253,-38.1671819,zoom=5) %>% 
  addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
           attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
  addPolygons(
    weight = 1,
    color = '#444444',
    fillOpacity = 0.2,
    fillColor = topo.colors(10, alpha = NULL),
    layerId = geoID,
    label=~geoNAME,
    labelOptions= labelOptions(direction = 'auto'),
    highlightOptions = highlightOptions(
      color='#ff0000', opacity = 1, weight = 2, fillOpacity = 1,
      bringToFront = TRUE, sendToBack = TRUE))

