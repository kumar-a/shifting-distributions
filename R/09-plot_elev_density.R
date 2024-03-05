# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Author: Abhishek Kumar
# Affiliation: Panjab University, Chandigarh
# Email: abhikumar.pu@gmail.com
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# load packages 
library(tidyverse)

## read the suitable elevation
read_csv("output/suitability_elevation.csv") |>
  mutate(species = gsub("\\.", "\n", species),
         scen = factor(scen, c("current", "2040", "2070", "2100"))) |>
  
  ## plot elevation density
  ggplot(aes(x = elevation/1e3, fill = scen, color = scen)) +
  geom_density(alpha = 0.2, bw = "nrd0", kernel = "gaussian", n = 512) +
  scale_color_manual(values = scen_pal) +
  scale_fill_manual( values = scen_pal) +
  guides(fill = guide_legend(nrow = 2, byrow=TRUE),
         color = guide_legend(nrow = 2, byrow=TRUE)) +
  facet_wrap(. ~ species, ncol = 4, scales = "free_y") +
  labs(x = "Elevation (km)", y = "Pixel density") +
  theme(legend.position = c(0.7, 0.125), legend.title = element_blank(),
        legend.background = element_rect(fill = NA, color = "grey"),
        panel.grid.major.x = element_line(color = "grey95", linewidth = 0.25),
        strip.background = element_blank(),
        strip.text = element_text(hjust = 0, face = "italic", size = 9))

## save the plots
ggsave("figs/07-elev_density.pdf", width = 7, height = 5)
ggsave("figs/07-elev_density.png", width = 7, height = 5, dpi = 600)
