################################################################################
## Author: Abhishek Kumar
## Affiliation: Panjab University, Chandigarh
## Email: abhikumar.pu@gmail.com
################################################################################

## load required packages
library(sf)
library(terra)
library(tidyverse)

################################################################################

## chosen 15 species and their known elevation ranges
# tribble(
#   ~species,                   ~LL,  ~UL,
#   "Abies pindrow",            2000, 3500,
#   "Betula utilis",            2500, 4500,
#   "Cedrus deodara",           1500, 2500,
#   "Lyonia ovalifolia",        1500, 3000,
#   "Mallotus philippensis",     300, 2000,
#   "Picea smithiana",          2100, 3500,
#   "Pinus roxburghii",         1000, 2300,
#   "Pinus wallichiana",        1800, 3000,
#   "Quercus lanata",           1500, 3000,
#   "Quercus floribunda",       2000, 3000,
#   "Quercus leucotrichophora", 1500, 2500,
#   "Quercus semecarpifolia",   2500, 3500,
#   "Rhododendron arboreum",    1500, 3000,
#   "Shorea robusta",            300, 1500,
#   "Taxus wallichiana",        2000, 3500
# ) |>
#   ## match plant names to WCVP
#   rWCVP::wcvp_match_names(name_col = "species", progress_bar = FALSE) |>
#   ## filter wcvp status
#   filter(wcvp_status == "Accepted") |>
#   ## join accepted names and family
#   left_join(
#     rWCVPdata::wcvp_names, by = c("wcvp_accepted_id" = "plant_name_id")
#   ) |>
#   select(taxon_name, taxon_authors, family, LL, UL) |>
#   write_excel_csv("data/selected_species.csv")

################################################################################

## Western Himalayan States
wh <- st_read("data/site_states.gpkg", quiet = TRUE) |>
  filter(STATE %in% c("Himachal Pradesh", "Uttarakhand"))

## selected species with elevation ranges
selected_species <- read.csv("data/selected_species.csv") |>
  select(taxon_name, LL, UL)


## species occurrences
spoc <- read.csv("output/species_occ_gbif.csv") |>
  mutate(reference = "GBIF2023") |>
  bind_rows(
    mutate(read.csv("data/species_occ_field.csv"), reference = "Field"),
    read.csv("data/species_occ_literature.csv")
  ) |>
  ## records for chosen species
  filter(species %in% selected_species$taxon_name) |>
  ## records inside the study area
  filter(
    between(longitude, 75.59459, 81.04661) &
      between(latitude,  28.72283, 33.25643)
  ) |>
  rownames_to_column("ID") |>
  mutate(ID = as.numeric(ID))

## tree cover fraction for each pixel (30 arc sec)
landcover <- terra::extract(
  rast("data/wh_worldcover_trees.tif"),
  vect(spoc, geom = c("longitude", "latitude"), crs = "epsg:4326")
)

## elevation value for each pixel
elev <- terra::extract(
  rast("output/wh_elev.tif"),
  vect(spoc, geom = c("longitude", "latitude"), crs = "epsg:4326")
) |> rename("elevation" = "file2e487213705e")

## clean species occurrences based on tree cover and elevational ranges
spoc_cleaned <- spoc |>
  ## add tree cover data
  left_join(landcover, by = join_by(ID)) |>
  ## add elevation 
  left_join(elev, by = join_by(ID)) |>
  ## add elevational ranges
  left_join(
    selected_species, by = join_by("species" == "taxon_name")
  ) |>
  ## filter occurrences with more 50% tree cover
  filter(trees >= 0.5) |>
  ## filter occurrences within known elevational ranges
  filter(between(elevation, LL, UL))

################################################################################

## function to randomly sub-sample species occurrences for minimising bias

## df.spoc: dataframe with species occurrence
## spc.col: column name for species
## lon.col: column name for longitude
## lat.col: column name for latitude
## cell.res: resolution of cell size in degrees, default to 1/5

thin.spoc <- function(df.spoc, spc.col = "species", 
                      lon.col = "longitude",lat.col = "latitude",
                      cell.res = 1/5){
  
  ## get unique species
  sp.unique <- df.spoc[, which(names(df.spoc) == spc.col)] |> unique()
  
  ## create an empty data list for saving the selected records
  datalist <- list()
  
  ## loop for all species
  for(i in 1:length(sp.unique)){
    
    ## spatVector for species occurrence
    spv <- subset(df.spoc, df.spoc[, spc.col] == sp.unique[i]) |>
      vect(geom = c(lon.col, lat.col), crs = "epsg:4326")
    
    ## create a SpatRaster with the extent of species occurrence
    r <- rast(spv)
    
    ## set the resolution of the cells (default = 0.2 degrees)
    res(r) <- cell.res
    
    ## extend (expand) the extent of the SpatRaster a little
    r <- extend(r, ext(r) + 1)
    
    ## seed for reproducibility
    set.seed(261294)
    
    ## sample species occurrences
    spsel <- spatSample(
      spv, size = 1, method = "random", strata = r, chess = ""
    ) |> as.data.frame()
    
    ## add sampled records to the empty datalist
    datalist[[i]] <-  spsel
  }
  
  ## combine data-lists into a data frame
  thinned_occ <- do.call(bind_rows, datalist)
  
  ## return sampled species occurrences
  return(thinned_occ)
}

################################################################################

## get ID for sampled species occurrences within each cell
id_thinned <- thin.spoc(spoc_cleaned)

## spatial thinning to minimise sampling bias
spoc_cleaned |>
  filter(ID %in% id_thinned$ID) |>
  # count(species, sort = TRUE)

  ## filter species with less than 20 occurrences
  filter(!species %in% c("Abies pindrow",   "Betula utilis", 
                         "Picea smithiana", "Pinus wallichiana",
                         "Quercus floribunda"
                         )) |>

  ## write cleaned occurrences to local directory
  write.csv("output/cleaned_occ.csv", row.names = FALSE)

