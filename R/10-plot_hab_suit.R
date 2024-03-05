# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Author: Abhishek Kumar
# Affiliation: Panjab University, Chandigarh
# Email: abhikumar.pu@gmail.com
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# 1. load packages ----
library(sf)
library(tidyverse)

# function to get model predictions

hab.suit <- function(sp){
  
  library(terra)
  
  ## scenarios for species presence
  scen <- c("current", "2040", "2070", "2100")
  
  ## get binary ensemble predictions
  sp_rast <- paste0(
    "models/", sp, "/proj_", scen, "/proj_", scen, "_", sp, "_ensemble.tif"
  ) |> 
    rast() |> 
    ## subset EMwmean algorithm
    subset(c(2, 4, 6, 8))
  
  ## rename full names to scenarios only
  names(sp_rast) <- scen
  
  ## return scenario with habitat suitability
  sp_rast |> 
    as.data.frame(xy = TRUE) |>
    mutate(species = sp) |> 
    pivot_longer(cols = c("current", "2040", "2070", "2100"),
                 names_to = "scen", values_to = "vals") |>
    mutate(scen = ifelse(scen == "current", yes = "Current", scen)) |>
    mutate(scen = factor(scen, c("Current", "2040", "2070", "2100")))
}

# theme for ggplot
theme_set(
  theme_bw(base_size = 12) +
    theme(panel.grid = element_blank(),
          legend.position = "bottom", 
          legend.title = element_text(size = 10),
          axis.title = element_blank(),
          axis.text = element_blank(), 
          axis.ticks = element_blank(),
          strip.background = element_blank(),
          strip.text.x = element_text(face = "italic", hjust = 0, size = 7),
          strip.text.y = element_text(face = "bold", hjust = 0.5, size = 8, angle = 90)
          )
)

# 2. load data ----

## 2.1 Western Himalayan States ----
wh <- st_read("data/site_states.gpkg", quiet = TRUE) |>
  filter(STATE %in% c("Himachal Pradesh", "Uttarakhand")) |>
  ## simplify geometry to 1 km buffer
  sf::st_simplify(preserveTopology = TRUE, dTolerance = 1e3)

## 2.2 habitat suitability data (subset1) ----
suit1 <- bind_rows(
  hab.suit("Cedrus.deodara"),
  hab.suit("Lyonia.ovalifolia"),
  hab.suit("Mallotus.philippensis"),
  hab.suit("Pinus.roxburghii"),
  hab.suit("Quercus.lanata")
) |>
  mutate(species = gsub("\\.", "\n", species))

## 2.3 habitat suitability data (subset2) ----
suit2 <- bind_rows(
  hab.suit("Quercus.leucotrichophora"),
  hab.suit("Quercus.semecarpifolia"),
  hab.suit("Rhododendron.arboreum"),
  hab.suit("Shorea.robusta"),
  hab.suit("Taxus.wallichiana")
) |>
  mutate(species = gsub("\\.", "\n", species))

# 3. plot maps ----

## 3.1 habitat suitability (subset1) ----
p1 <- ggplot() +
  geom_raster(data = suit1, aes(x, y, fill = vals/1e3)) +
  facet_grid(scen ~ species, switch = "y") +
  scale_fill_distiller(
    palette = "BuGn", direction = 1, name = "Suitability",
    breaks = seq(0, 1, 0.2), 
    guide = guide_legend(title.vjust = 0.5, nrow = 1, 
                         keywidth = 0.5, keyheight = 0.5)
  ) +
  scale_x_continuous(NULL, expand = c(0, 0)) +
  scale_y_continuous(NULL, expand = c(0, 0)) +
  geom_sf(data = wh, fill = NA)

## 3.2 future range change (subset2) ----
p2 <- ggplot() +
  geom_raster(data = suit2, aes(x, y, fill = vals/1e3)) +
  facet_grid(scen ~ species, switch = "y") +
  scale_fill_distiller(
    palette = "BuGn", direction = 1, name = "Suitability",
    breaks = seq(0, 1, 0.2), guide = guide_legend(title.vjust = 0.5)
  ) +
  scale_x_continuous(NULL, expand = c(0, 0)) +
  scale_y_continuous(NULL, expand = c(0, 0)) +
  geom_sf(data = wh, fill = NA)

# 4. arrange maps ----

prow <- cowplot::plot_grid(
  p1 + theme(legend.position="none"),
  p2 + theme(legend.position="none"),
  ncol = 1
)

## get the legend
plegend <- cowplot::get_legend(p1)

## plot maps and legend
cowplot::plot_grid(
  prow, plegend, rel_heights = c(0.95, 0.05), ncol = 1
)

# 5. save map
ggsave("figs/s05-hab_suit.pdf", width = 8, height = 5)
ggsave("figs/s05-hab_suit.png", width = 8, height = 5, dpi = 600)
