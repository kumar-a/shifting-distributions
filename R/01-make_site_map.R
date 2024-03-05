################################################################################
## Author: Abhishek Kumar
## Affiliation: Panjab University, Chandigarh
## Email: abhikumar.pu@gmail.com
################################################################################

## load the required packages
library(sf)
library(terra)
library(tmap)
library(tidyverse)

#################################
## ----- make an inset map -----
################################

## International spatial boundaries
indsub <- st_read("data/ind_subcont.gpkg", quiet = TRUE) |>
  ## remove some country names
  mutate(NAME = ifelse(
    NAME %in% c("Afghanistan", "Pakistan", "India", 
                "Nepal", "Myanmar", "China"), 
    yes = NAME, no = NA
  ))

## Outline for Hindu Kush Himalaya
hkh <- st_read("data/hkh/outline.shp", quiet = TRUE) |>
  mutate(Name = "Hindu Kush Himalaya")

## Indian states covering Western Himalayas
wh_states <- st_read("data/site_states.gpkg", quiet = TRUE) |>
  st_transform(crs = st_crs(4326)) |>
  filter(STATE %in% c("Himachal Pradesh", "Uttarakhand"))


## bounding box for main map
main_bbox <- st_bbox(
  c(xmin = 75.50, ymin = 28.70, xmax = 81.06, ymax = 33.27),
  crs = st_crs(4326)
) |> st_as_sfc()

## prepare inset map
inset_map <- tm_shape(indsub, bbox = hkh) + 
  tm_fill(col = "grey95") +
  
  tm_shape(hkh) + 
  tm_fill(col = "grey75") + 
  
  tm_shape(indsub, bbox = hkh) + 
  tm_borders(col = "grey55", lwd = 0.5) + 
  tm_text("NAME", col = "grey30", size = 0.4) +
  
  tm_shape(hkh) + 
  tm_text("Name", col = "black", size = 0.6) +
  
  tm_shape(main_bbox) + 
  tm_fill(col = "lightpink", alpha = 0.5) + 
  tm_borders(col = "red", lwd = 0.5) +
  
  tm_layout(bg.color = "lightskyblue",
            frame.lwd = 0.25)

#################################################################
## ----- download and prepare data for main map -----
#################################################################

## Download and save elevation data
# main_bbox |> elevatr::get_elev_raster(z = 7) |>
#   rast() |>
#   writeRaster("output/wh_elev.tif", overwrite=TRUE)

elev <- rast("output/wh_elev.tif") |> 
  crop(vect(main_bbox))

## Calculate hill shade
slope  <- terrain(elev, "slope",  unit = "radians")
aspect <- terrain(elev, "aspect", unit = "radians")
hs <- shade(slope, aspect)

## masked elevation for India
wh_elev <- elev |> mask(vect(wh_states))

## switch off spherical geometry
sf_use_s2(FALSE)

## masked elevation for Western Himalayas
wh_states_inverse <- st_sym_difference(main_bbox, summarise(wh_states))

## cleaned species occurrences
spoc <- read.csv("output/cleaned_occ.csv") |>
  select(ID:longitude) |>
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

################################################################################

tmap_mode("plot")

## Make the map
main_map <- tm_shape(hs) +
  tm_raster(palette = "-Greys", legend.show = FALSE) + 
  tm_graticules(labels.size = 0.75, lines = FALSE) +
  
  tm_shape(elev) + 
  tm_raster(palette = terrain.colors(8), alpha = 0.5,
            breaks = c(0, seq(500, 5000, 1000), Inf),
            title = "Elevation (m)", legend.reverse = TRUE) +
  
  tm_shape(wh_states_inverse) +
  tm_fill(col = "grey80", alpha = 0.5) +
  
  tm_shape(spoc) +
  tm_symbols(size = 0.1, shape = 21, alpha = 0.75, 
             col = "grey90", border.col = "grey20", border.lwd = 0.5) +
  
  tm_shape(wh_states, bbox = main_bbox) + 
  tm_borders(lwd = 0.75, col = "grey30") +
  tm_text("STATE", bg.color = "white", bg.alpha = 0.75) +
  
  tm_add_legend(type = "symbol", labels = "Species occurrence", 
                col = "grey90", border.col = "grey20", border.lwd = 0.5,
                size = 0.5, shape = 21, alpha = 0.75) +
  
  tm_compass(size = 1.5, position = c(0.0, 0.99), just = c("left", "top")) +
  tm_scale_bar(position = c(0.3, 0.01), just = c("left", "bottom")) +
  
  tm_layout(inner.margins = 0,
            legend.just = c("left", "bottom"),
            legend.position = c(0.01, 0.01),
            legend.bg.color = "grey80",
            legend.bg.alpha = 0.9,
            legend.text.size = 0.75,
            legend.title.size = 1,
            frame.lwd = 0.5)

inset_asp <- (39.31873 - 15.95789)/(105.0447 - 60.85388)

# ## arrange and save maps
myvp <- grid::viewport(
  x = 1, y = 0.94, just = c("right", "top"),
  width = unit(2.25, "inches"), 
  height = unit(inset_asp*2.25, "inches")
)

## save map to local disk
tmap_save(main_map, filename = "figs/02-site_map.pdf", insets_tm = inset_map,
          insets_vp = myvp, width = 6, height = 6, units = "in")
tmap_save(main_map, filename = "figs/02-site_map.png", insets_tm = inset_map,
          insets_vp = myvp, width = 6, height = 6, units = "in", dpi = 600)
