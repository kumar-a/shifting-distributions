# Author: Abhishek Kumar
## Affiliation: Panjab University, Chandigarh
## Email: abhikumar.pu@gmail.com
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

## date: 2023-10-12

## Citation:
## @book{
##    title={Habitat Suitability and Distribution Models: With Applications in R},
##    author={Guisan, A. and Thuiller, W. and Zimmermann, N.E.},
##    isbn={9780521758369},
##    series={Ecology, Biodiversity and Conservation},
##    year={2017},
##    publisher={Cambridge University Press}
## }
##

## load the required packages
library(biomod2)
library(terra)
library(tidyverse)

# 1. Data preparation -----

## 1.1 species occurrence ----
mallotus_occ <- read.csv("output/cleaned_occ.csv") |>
  filter(species == "Mallotus philippensis") |>
  select(species, longitude, latitude)

## 1.2 current climate ----
bio_current <- rast("data/wh_bio_2010_current.tif") |>
  subset(c(2, 3, 8, 14, 15, 18))
names(bio_current) <- paste0("bio", c(2, 3, 8, 14, 15, 18))


## 1.3 future climate ----
bio_2040 <- rast("data/wh_bio_2040_ssp126.tif")
names(bio_2040) <- paste0("bio", c(2, 3, 8, 14, 15, 18))

bio_2070 <- rast("data/wh_bio_2070_ssp126.tif")
names(bio_2070) <- paste0("bio", c(2, 3, 8, 14, 15, 18))

bio_2100 <- rast("data/wh_bio_2100_ssp126.tif")
names(bio_2100) <- paste0("bio", c(2, 3, 8, 14, 15, 18))

## 1.4 format the data ----

### random sampling of background points
tmp <- Sys.time()
mallotus_data_random <- BIOMOD_FormatingData(
  resp.name = "mp",
  resp.var  = rep(1, nrow(mallotus_occ)), 
  resp.xy   = mallotus_occ[, c("longitude", "latitude")],
  expl.var  = bio_current,
  dir.name  = "models",
  PA.nb.rep = 5, ## sets of pseudo-absence
  PA.nb.absences = c(250, 500, 1000, 2000, 5000), ## number of pseudo-absence
  PA.strategy = "random",
  filter.raster = TRUE
)
Sys.time() - tmp

### disk sampling of background points
tmp <- Sys.time()
mallotus_data_disk <- BIOMOD_FormatingData(
  resp.name = "mp",
  resp.var  = rep(1, nrow(mallotus_occ)), 
  resp.xy   = mallotus_occ[, c("longitude", "latitude")],
  expl.var  = bio_current,
  dir.name  = "models",
  PA.nb.rep = 5, ## sets of pseudo-absence
  PA.nb.absences = c(250, 500, 1000, 2000, 5000), ## number of pseudo-absence
  PA.strategy = "disk",
  PA.dist.min = 1000,
  PA.dist.max = 1000*50,
  filter.raster = TRUE
)
Sys.time() - tmp


## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# 2. Modelling ----

## 2.1 define individual models options ---- 
mallotus_opt <- BIOMOD_ModelingOptions(
  MAXENT = list(
    path_to_maxent.jar = file.path(getwd(), "maxent/maxent.jar"),
    memory_allocated = 1024
  )
)

## 2.2 run the MaxEnt individual models ----
tmp <- Sys.time()
mallotus_models_random <- BIOMOD_Modeling(
  bm.format = mallotus_data_random,
  modeling.id = "randommods",
  models = c("MAXENT"),
  bm.options = mallotus_opt,
  CV.strategy = "random",
  CV.nb.rep = 3,
  CV.perc = 0.7,
  metric.eval = c("TSS", "ROC"),
  var.import = 3,
  seed.val = 261294
)
Sys.time() - tmp


tmp <- Sys.time()
mallotus_models_disk <- BIOMOD_Modeling(
  bm.format = mallotus_data_disk,
  modeling.id = "diskmods",
  models = c("MAXENT"),
  bm.options = mallotus_opt,
  CV.strategy = "random",
  CV.nb.rep = 3,
  CV.perc = 0.7,
  metric.eval = c("TSS", "ROC"),
  var.import = 3,
  seed.val = 261294
)
Sys.time() - tmp

## effect of sampling method and number of background points
get_evaluations(mallotus_models_disk) |>
  mutate(pa.meth = "Disk") |>
  bind_rows(
    mutate(get_evaluations(mallotus_models_random), pa.meth = "Random")
  ) |>
  write.csv("output/mallotus_background.csv", row.names = FALSE)
