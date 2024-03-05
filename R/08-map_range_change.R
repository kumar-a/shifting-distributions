# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Author: Abhishek Kumar
# Affiliation: Panjab University, Chandigarh
# Email: abhikumar.pu@gmail.com
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# 1. load packages ----
library(sf)
library(tidyverse)

## Western Himalayan States
wh <- st_read("data/site_states.gpkg", quiet = TRUE) |>
  filter(STATE %in% c("Himachal Pradesh", "Uttarakhand")) |>
  ## simplify geometry to 1 km buffer
  sf::st_simplify(preserveTopology = TRUE, dTolerance = 5e-3)

## species range data (subset1)
sp_range1 <- list.files(
  path = "output/range_dynamics",
  pattern = "src_comm_avg.csv",
  full.names = TRUE
) |>
  read_csv(id = "path") |>
  mutate(path = gsub("output/range_dynamics/|_current_to|_src_comm_avg.csv", "", path)) |>
  separate(path, into = c("species", "year"), sep = "_") |>
  filter(species %in% c("Cedrus.deodara", "Mallotus.philippensis", "Quercus.lanata",
                        "Quercus.semecarpifolia", "Shorea.robusta")) |>
  mutate(species = gsub("\\.", "\n", species))

## species range data (subset2)
sp_range2 <- list.files(
  path = "output/range_dynamics",
  pattern = "src_comm_avg.csv",
  full.names = TRUE
) |>
  read_csv(id = "path") |>
  mutate(path = gsub("output/range_dynamics/|_current_to|_src_comm_avg.csv", "", path)) |>
  separate(path, into = c("species", "year"), sep = "_") |>
  filter(!species %in% c("Cedrus.deodara", "Mallotus.philippensis", "Quercus.lanata",
                         "Quercus.semecarpifolia", "Shorea.robusta")) |>
  mutate(species = gsub("\\.", "\n", species))

## future range change (subset1)
p1 <- ggplot() +
  geom_raster(data = sp_range1, aes(x, y, fill = as.factor(value))) +
  facet_grid(species ~ year, switch = "y") +
  scale_fill_manual(values = c("-2" = "#d8b365", "-1" = "#e1e1e1", "1" = "#5ab4ac"),
                    labels = c("-2" = "Loss", "-1" = "Stable", "1" = "Gain"),
                    guide = guide_legend(title.vjust = 0.5, nrow = 1,
                                         keywidth = 0.5, keyheight = 0.5)
                    ) +
  scale_x_continuous(NULL, expand = c(0, 0)) +
  scale_y_continuous(NULL, expand = c(0, 0)) +
  geom_sf(data = wh, fill = NA) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        axis.text = element_blank(), axis.ticks = element_blank(),
        axis.title = element_blank(),
        strip.text.y.left = element_text(face = "italic", angle = 90,
                                         hjust = 0, size = 8))

## future range change (subset2)
p2 <- ggplot() +
  geom_raster(data = sp_range2, aes(x, y, fill = as.factor(value))) +
  facet_grid(species ~ year, switch = "y") +
  scale_fill_manual(values = c("-2" = "#d8b365", "-1" = "#e1e1e1", "1" = "#5ab4ac"),
                    labels = c("-2" = "Loss", "-1" = "Stable", "1" = "Gain")) +
  scale_x_continuous(NULL, expand = c(0, 0)) +
  scale_y_continuous(NULL, expand = c(0, 0)) +
  geom_sf(data = wh, fill = NA) +
  theme(legend.position = "bottom", legend.title = element_blank(),
        axis.text = element_blank(), axis.ticks = element_blank(),
        axis.title = element_blank(),
        strip.text.y.left = element_text(face = "italic", angle = 90,
                                         hjust = 0, size = 8))

## arrange maps
prow <- cowplot::plot_grid(
  p1 + theme(legend.position="none"),
  p2 + theme(legend.position="none")
)

## get the legend
plegend <- cowplot::get_legend(p1)

## plot maps and legend
cowplot::plot_grid(
  prow, plegend, rel_heights = c(0.95, 0.05), ncol = 1
)

# ## save map ----
ggsave("figs/05-range_change.pdf", width = 8, height = 6)
ggsave("figs/05-range_change.png", width = 8, height = 6, dpi = 600)
