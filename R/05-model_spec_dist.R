## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## Author: Abhishek Kumar
## Affiliation: Panjab University, Chandigarh
## Email: abhikumar.pu@gmail.com
## date: 2023-10-17
## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

## Reference:
## @book{
##    title={Habitat Suitability and Distribution Models: With Applications in R},
##    author={Guisan, A. and Thuiller, W. and Zimmermann, N.E.},
##    isbn={9780521758369},
##    series={Ecology, Biodiversity and Conservation},
##    year={2017},
##    publisher={Cambridge University Press},
##    address={Cambridge}
## }

## load the required packages
library(biomod2)
library(terra)
library(tidyverse)


# 1. Data preparation -----

## 1.1 species occurrence ----
spp_occ <- read.csv("output/cleaned_occ.csv") |>
  select(species, longitude, latitude) |>
  mutate(species = gsub(" ", ".", species))

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


## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# 2. biomod wrapper function ----
biomod.wrapper <- function(sp){
  cat("\n> species : ", sp)
  
  ## 2.1 get occurrences points ----
  sp_dat <- spp_occ[spp_occ$species == sp, ]
  
  ## 2.2 formatting the data ----
  sp_format <- BIOMOD_FormatingData(
    resp.name = sp,
    resp.var  = rep(1, nrow(sp_dat)), 
    resp.xy   = sp_dat[, c("longitude", "latitude")],
    expl.var  = bio_current,
    dir.name  = "./models",
    PA.nb.rep = 3, ## three sets of pseudo-absence (background for maxent)
    PA.nb.absences = 1e3, ## 1,000 pseudo-absence (background for maxent)
    PA.strategy    = "random",
    filter.raster  = TRUE
  )
  
  ## print formatting summary
  sp_format
  
  ## define models options (default)
  sp_opt <- BIOMOD_ModelingOptions(MAXENT = list(
    path_to_maxent.jar = 'E:/GitHub/shifting-distributions/maxent/maxent.jar',
    # path_to_maxent.jar = "C:/Users/Abhi/Documents/maxent/maxent.jar",
    
    memory_allocated = 1024, # Changed from default of 512
    initial_heap_size = NULL, maximum_heap_size = NULL,
    background_data_dir = 'default', maximumbackground = 'default',
    maximumiterations = 500, # Changed from default of 200
    visible = FALSE,
    
    ## model features and parameters
    linear = TRUE, quadratic = TRUE, product = TRUE, threshold = TRUE, hinge = TRUE,
    lq2lqptthreshold = 80, l2lqthreshold = 10, hingethreshold = 15, 
    beta_threshold = -1, beta_categorical = -1, beta_lqp = -1, beta_hinge = -1,
    betamultiplier = 1, defaultprevalence = 0.5
    ))
  
  ## 2.3 build MaxEnt model ----
  sp_model <- BIOMOD_Modeling(
    bm.format = sp_format,
    modeling.id = "allmods",
    models = c("MAXENT"),
    bm.options = sp_opt,
    CV.strategy = "random",
    CV.nb.rep = 4, ## number of cross-validations
    CV.perc = 0.7, ## 70% for calibration and 30% for validation
    CV.do.full.models = FALSE,
    metric.eval = c("TSS", "ROC"),
    var.import = 3,
    seed.val = 261294
  )
  
  ## save single model evaluation scores
  get_evaluations(sp_model) |>
    write.csv(file = paste0("output/mod_eval/", sp, "_single_eval_scores.csv"),
              row.names = FALSE)
  
  ## save single model variable importance
  get_variables_importance(sp_model) |>
    write.csv(file = paste0("output/mod_eval/", sp, "_single_var_imp.csv"),
              row.names = FALSE)
  
  ## save single model response curves
  bm_PlotResponseCurves(bm.out = sp_model, models.chosen = "all",
                       do.plot = FALSE)$tab |>
    write.csv(file = paste0("output/mod_eval/", sp, "_single_resp_curve.csv"),
              row.names = FALSE)
 
  
  ## 2.4 build ensemble models ----
  sp_ens_model <- BIOMOD_EnsembleModeling(
    bm.mod = sp_model,
    models.chosen = "all",
    em.by = "all",
    em.algo = c("EMca", "EMwmean"), 
    metric.select = c("TSS"),
    metric.select.thresh = c(0.7),
    metric.eval = c("TSS", "ROC"),
    var.import = 3,
    seed.val = 261294
  )
  
  ## save ensemble model evaluation scores
  get_evaluations(sp_ens_model) |>
    write.csv(file = paste0("output/mod_eval/", sp, "_ensemble_eval_scores.csv"),
              row.names = FALSE)

  ## save ensemble model variable importance
  get_variables_importance(sp_ens_model) |>
    write.csv(file = paste0("output/mod_eval/", sp, "_ensemble_var_imp.csv"),
              row.names = FALSE)
  
  ## save ensemble model variable importance
  bm_PlotResponseCurves(bm.out = sp_ens_model, models.chosen = "all",
                       do.plot = FALSE)$tab |>
    write.csv(file = paste0("output/mod_eval/", sp, "_ensemble_resp_curve.csv"),
              row.names = FALSE)
  
  ## 2.5 projections ----
  
  proj_scen <- c("current", "2040", "2070", "2100")
  
  for(scen in proj_scen){
    cat("\n> projections of ", scen)
    
    ### single model projections
    sp_proj <- BIOMOD_Projection(
      bm.mod = sp_model,
      proj.name = scen,
      new.env = get(paste0("bio_", scen)),
      models.chosen = "all",
      metric.binary = "all",
      metric.filter = "all",
      build.clamping.mask = TRUE
    )
    
    ### ensemble model projections
    sp_ens_proj <- BIOMOD_EnsembleForecasting(
      bm.em = sp_ens_model,
      bm.proj = sp_proj,
      models.chosen = "all",
      metric.binary = "all",
      metric.filter = "all"
    )
  }
  
  ## 2.6 species range change ----
  
  ### current binary projection
  sp_current <- paste0(
    "models/", sp, "/proj_current/proj_current_", sp, "_ensemble_TSSbin.tif"
  ) |> rast()
  
  ### future year scenarios
  future_yr <- c("2040", "2070", "2100")
  
  ### compute future range dynamics
  for(yr in future_yr){
    
    ## load binary projection
    sp_yr <- paste0(
      "models/", sp, "/proj_", yr, "/proj_", yr, "_", sp, "_ensemble_TSSbin.tif"
    ) |> rast()
    
    ## species range change
    sp_current_to_yr <- BIOMOD_RangeSize(
      proj.current = sp_current, 
      proj.future  = sp_yr
    ) |>
      ## get summary of count, percentage, averaging and agreement
      bm_PlotRangeSize(do.count = TRUE, do.perc  = TRUE, do.maps  = FALSE,  
                       do.mean  = TRUE, do.plot = FALSE, row.names = c("Species"))
    
    ## save pixel count and percentage
    write.csv(
      sp_current_to_yr$tab.count,
      paste0("output/range_dynamics/", sp, "_current_to_", yr, "_src_count.csv"),
      row.names = FALSE
    )
    
    ## save community averaging value
    write.csv(
      dplyr::select(sp_current_to_yr$tab.ca1, x, y, value),
      paste0("output/range_dynamics/", sp, "_current_to_", yr, "_src_comm_avg.csv"),
      row.names = FALSE
    )
    
    ## save percentage of model agreement
    write.csv(
      dplyr::select(sp_current_to_yr$tab.ca2, x, y, value),
      paste0("output/range_dynamics/", sp, "_current_to_", yr, "_src_mod_agree.csv"),
      row.names = FALSE
    )
    
  }
  
  return(paste0(sp," modelling completed !"))
}


## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# 3. model species distribution ----

## Each model may take 30-40 mins
## some model may throw Permission denied error due to unknown reason
## consider retrying individually

# tmp <- Sys.time()
# biomod.wrapper("Cedrus.deodara")
# Sys.time() - tmp ## 30-40 mins
# 
# tmp <- Sys.time()
# biomod.wrapper("Lyonia.ovalifolia")
# Sys.time() - tmp ## 30 mins
# 
# tmp <- Sys.time()
# biomod.wrapper("Mallotus.philippensis")
# Sys.time() - tmp ## 30 mins
# 
# tmp <- Sys.time()
# biomod.wrapper("Pinus.roxburghii")
# Sys.time() - tmp ## 30-40 mins
# 
# tmp <- Sys.time()
# biomod.wrapper("Quercus.lanata")
# Sys.time() - tmp ## 30-40 mins
# 
# tmp <- Sys.time()
# biomod.wrapper("Quercus.leucotrichophora")
# Sys.time() - tmp ## 30-40 mins
# 
# tmp <- Sys.time()
# biomod.wrapper("Quercus.semecarpifolia")
# Sys.time() - tmp ## 30-40 mins
# 
# tmp <- Sys.time()
# biomod.wrapper("Rhododendron.arboreum")
# Sys.time() - tmp ## 30 mins
# 
# tmp <- Sys.time()
# biomod.wrapper("Shorea.robusta")
# Sys.time() - tmp ## 30 mins

# tmp <- Sys.time()
# biomod.wrapper("Taxus.wallichiana")
# Sys.time() - tmp ## 30-35 mins

## +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

