################################################################################
## Author: Abhishek Kumar
## Affiliation: Panjab University, Chandigarh
## Email: abhikumar.pu@gmail.com
################################################################################

## load required packages
library(rgbif)
library(tidyverse)

################################################################################

## get GBIF taxon keys
gbif_taxon_keys <- read.csv("data/site_plants_wcvp.csv") |>
  ## remove duplicate names
  distinct(taxon_name) |>
  ## match to gbif backbone
  name_backbone_checklist() |>
  ## filter matched species
  filter(matchType == "EXACT") |>
  ## get the gbif taxonkeys
  pull(usageKey)

## bounding box for Western Himalayas [gbif expects counter-clockwise]
wh_wkt <- "POLYGON((73.39 28.72,81.05 28.72,81.05 35.13,73.39 35.13,73.39 28.72))"

# use matched gbif_taxon_keys from above 
occ_download(
  pred_in("taxonKey", gbif_taxon_keys),
  pred_in("basisOfRecord", c('PRESERVED_SPECIMEN','HUMAN_OBSERVATION','OBSERVATION','MACHINE_OBSERVATION')),
  pred("country", "IN"),
  pred_within(wh_wkt),
  pred("hasCoordinate", TRUE),
  pred("hasGeospatialIssue", FALSE),
  pred("occurrenceStatus","PRESENT"), 
  pred_gte("year", 1980),
  format = "SIMPLE_CSV"
)

## Check status with
occ_download_wait('0003213-230918134249559')

## After it finishes, get and import
d <- occ_download_get('0003213-230918134249559',
                      path = "output", overwrite = FALSE) |>
  occ_download_import()

## select species occurrence coordinates and save
d |> select(species, decimalLatitude, decimalLongitude) |>
  rename("latitude" = decimalLatitude, "longitude" = decimalLongitude) |>
  write.csv("output/species_occ_gbif.csv", row.names = FALSE)
