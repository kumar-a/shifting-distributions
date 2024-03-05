# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Author: Abhishek Kumar
# Affiliation: Panjab University, Chandigarh
# Email: abhikumar.pu@gmail.com
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# load packages
library(terra)
library(tidyverse)

## function to retrieve elevation for predicted suitability
pres.elev <- function(sp){
  
  ## scenarios for species presence
  scen <- c("current", "2040", "2070", "2100")
  
  ## get binary ensemble predictions
  sp_rast <- paste0(
    "models/", sp, "/proj_", scen, "/proj_", scen, "_", sp, "_ensemble_TSSbin.tif"
  ) |> 
    rast() |> 
    ## subset EMca algorithm
    subset(c(1, 3, 5, 7)) |>
    ## substitute absence (0) to NA
    subst(from = 0, to = NA)
  
  ## rename full names to scenarios only
  names(sp_rast) <- scen
  
  ## convert to dataframe
  pres <- sp_rast |> as.data.frame(xy = TRUE)
  
  ## load elevation data
  elev <- rast("output/wh_elev.tif")
  names(elev) <- "elevation"
  
  ## extract elevation for selected points
  pres_elev <- elev |>
    terra::extract(
      dplyr::select(pres, x, y), ID = FALSE
    )
  
  ## return scenario with elevation
  bind_cols(
    pres, pres_elev
  ) |>
    mutate(species = sp) |> 
    pivot_longer(cols = c("current", "2040", "2070", "2100"),
                 names_to = "scen", values_to = "vals") |>
    filter(!is.na(vals)) |>
    mutate(scen = factor(scen, c("current", "2040", "2070", "2100"))) |>
    dplyr::select(species, scen, elevation)
}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

## get elevation data
tmp <- Sys.time()
bind_rows(
  pres.elev("Cedrus.deodara"),
  pres.elev("Lyonia.ovalifolia"),
  pres.elev("Mallotus.philippensis"),
  pres.elev("Pinus.roxburghii"),
  pres.elev("Quercus.lanata"),
  pres.elev("Quercus.leucotrichophora"),
  pres.elev("Quercus.semecarpifolia"),
  pres.elev("Rhododendron.arboreum"),
  pres.elev("Shorea.robusta"),
  pres.elev("Taxus.wallichiana")
) |> write_csv(file = "output/suitability_elevation.csv")
Sys.time() - tmp
