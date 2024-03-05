# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Author: Abhishek Kumar
# Affiliation: Panjab University, Chandigarh
# Email: abhikumar.pu@gmail.com
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# 1. load packages ----
library(tidyverse)

## response curves for ensemble models
ens_resp_curv <- list.files(
  path = "output/mod_eval",
  pattern = "ensemble_resp_curve.csv",
  full.names = TRUE
) |>
  read_csv() |>
  separate(pred.name, into = c("species", "algo"), sep = "_", extra = "drop") |>
  rename("Model" = algo)

## single model response curves
list.files(
  path = "output/mod_eval",
  pattern = "single_resp_curve.csv",
  full.names = TRUE
) |>
  read_csv() |>
  separate(pred.name, into = c("species", "PA", "RUN"), sep = "_", extra = "drop") |>
  unite("Model", PA, RUN, sep = "_") |>

  ## add ensemble model response curves
  bind_rows(ens_resp_curv) |>

  ## arrange and divide into Temperature and Precipitation
  mutate(expl.name = factor(expl.name, paste0("bio", c(2, 3, 8, 14, 15, 18))),
         expl.clim = ifelse(expl.name %in% c("bio2", "bio3", "bio8"),
                            yes = "Temp", no = "Prec")) |>

  ## prepare abbreviated species names
  separate(col = species, into = c("sp", "gn")) |>
  mutate(sp = abbreviate(sp, minlength = 1),
         gn = abbreviate(gn, minlength = 3)) |>
  unite(col = "species", sp, gn, sep = ".") |>

  ## plot the response curves
  ggplot(aes(x = expl.val, y = pred.val)) +
  geom_line(aes(group = Model), linewidth = 0.5, alpha = 0.5, color = "grey") +
  geom_smooth(aes(color = expl.clim), method = "gam",
              formula = y ~ s(x, bs = "cs")) +
  scale_color_manual(values = c("Temp" = "#d73027", "Prec" = "#4575b4")) +
  facet_grid(species ~ expl.name, scales = "free", switch = "y") +
  scale_x_continuous(n.breaks = 4) +
  scale_y_continuous(position = "right", n.breaks = 4) +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 45, size = 8, hjust = 1),
        axis.text.y = element_text(size = 8),
        axis.title = element_blank(),
        strip.text.x = element_text(face = "bold", hjust = 0.5),
        strip.text.y = element_text(face = "italic", angle = 90))

## save the single response curve
ggsave("figs/s07-resp_curve_single.pdf", width = 6, height = 8)
ggsave("figs/s07-resp_curve_single.png", width = 6, height = 8, dpi = 600)
