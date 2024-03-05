# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Author: Abhishek Kumar
# Affiliation: Panjab University, Chandigarh
# Email: abhikumar.pu@gmail.com
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

## load packages
library(sf)
library(terra)
library(tidyverse)

## Western Himalayan States
wh <- st_read("data/site_states.gpkg", quiet = TRUE) |>
  filter(STATE %in% c("Himachal Pradesh", "Uttarakhand")) |>
  ## simplify geometry to 1 km buffer
  sf::st_simplify(preserveTopology = TRUE, dTolerance = 5e-3)

## function to calculate species richness
sp.rich <- function(scen){
  
  ## names of selected species
  mysp <- c("Cedrus.deodara", "Lyonia.ovalifolia", "Mallotus.philippensis",
            "Pinus.roxburghii", "Quercus.lanata", "Quercus.leucotrichophora",
            "Quercus.semecarpifolia", "Rhododendron.arboreum", "Shorea.robusta",
            "Taxus.wallichiana")
  
  ## get paths of ensemble binary predictions
  myrast <- paste0("models/", mysp, "/proj_", scen, 
                   "/proj_", scen, "_", mysp, "_ensemble_TSSbin.tif") |>
    
    ## read the raster
    rast() |>
    
    ## subset EMca algorithm
    subset(seq(1, 19, 2)) |>
    
    ## calculate species richness
    sum()
  
  ## rename species richness
  names(myrast) <- scen
  
  ## return species richness
  return(myrast)
  
}

## calculate change in species richness
rich2010 <- sp.rich("current")
rich2010[rich2010 == 0] <- NA ## set 0 to NA
rich2040 <- rich2010 - sp.rich("2040")
rich2070 <- rich2010 - sp.rich("2070")
rich2100 <- rich2010 - sp.rich("2100")

## rename the rasters
names(rich2040) <- "2040"
names(rich2070) <- "2070"
names(rich2100) <- "2100"

## convert to data frame
rich_change <- c(rich2040, rich2070, rich2100) |>
  as.data.frame(xy = TRUE) |>
  pivot_longer(cols = -c(x, y), names_to = "scen", values_to = "richness") |>
  mutate(scen = factor(scen, c("2040", "2070", "2100")))

## load elevation data
elev <- rast("output/wh_elev.tif")
names(elev) <- "elevation"

## extract elevation data for richness change
rich_elev <- elev |>
  terra::extract(
    dplyr::select(rich_change, x, y), ID = FALSE
  )

## save the data
bind_cols(rich_change, rich_elev) |>
  write.csv("output/richness_elevation.csv", row.names = FALSE)
