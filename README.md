# Climate-driven elevational range dynamics of dominant trees in the Western Himalayas
**Authors:** [Abhishek Kumar](https://akumar.netlify.app/)<sup>#</sup>, [Meenu Patil](https://www.researchgate.net/profile/Meenu-Patil), [Pardeep Kumar](https://www.researchgate.net/profile/Pardeep-Kumar-22), [Anand Narain Singh](https://www.researchgate.net/profile/Anand-Singh-15)\*   
**Affiliation:** *Soil Ecosystem and Restoration Ecology Lab, Department of Botany, Panjab University, Chandigarh 160014, India*   
<sup>#</sup>Maintainer: abhikumar.pu@gmail.com  
\*Corresponding author: dranand1212@gmail.com; ansingh@pu.ac.in 

## Directory structure

```
.
  |- data
    |- hkh
    |- ind_subcont.gpkg
    |- ind0.gpkg
    |- selected_species.csv
    |- site_plants_wcvp.csv
    |- site_states.gpkg
    |- species_occ_field.csv
    |- species_occ_literature.bib
    |- species_occ_literature.csv
    |- wh_bio_2010_current.tif
    |- wh_bio_2040_ssp126.tif
    |- wh_bio_2070_ssp126.tif
    |- wh_bio_2100_ssp126.tif
    |- wh_worldcover_trees.tif
  |- figs
  |- maxent
  |- models
  |- output
    |- mod_eval
    |- range_dynamics
    |- 0003213-230918134249559.zip
    |- cleaned_occ.csv
    |- mallotus_background.csv
    |- richness_elevation.csv
    |- species_occ_gbif.csv
    |- suitability_elevation.csv
    |- wh_elev.tif
    |- WorldCover_trees_30s.tif
  |- R
    |- 01-make_site_map.R
    |- 02-get_gbif_occ.R
    |- 03-clean_species_occ.R
    |- 04-decide_background.R
    |- 05-model_spec_dist.R
    |- 06-get_spec_rich.R
    |- 07-get_suit_elev.R
    |- 08-map_range_change.R
    |- 09-plot_elev_density.R
    |- 10-plot_hab_suit.R
    |- 11-plot_resp_curve_single.R
  |- chicago-author-date.csl
  |- clean_occ.gv
  |- credit_author.csv
  |- index.qmd
  |- odmap_protocol.csv
  |- README.md
  |- refs.bib
  |- shifting-distributions.Rproj
  |- supp_info.qmd
```

## Description of directories

| Name               | Description                                             |  
| :------------------| :-------------------------------------------------------|
| [data](/data/)     | Directory for primary input data used for study         |
| [figs](/figs/)     | Directory for saving figures generated from the analysis|
| maxent             | Directory for `maxent.jar` and associated files         |
| models             | Directory for model files (to be populated after code run) |
| [output](/output/) | Directory for processed data generated from the analysis |
| [R](/R/)           | Directory for `R` scripts used to process and analyse data |

## Description of primary data files

| Name | Description |  
| :--- | :--- |
| [hkh](/data/hkh/) | Spatial boundary of Hindu Kush Himalayas (ICIMOD [2008](https://www.icimod.org/)) |
| [ind_subcont.gpkg](/data/ind_subcont.gpkg) | Spatial boundary for Indian Subcontinent |
| [ind0.gpkg](/data/ind0.gpkg) | Spatial boundary for India |
| [selected_species.csv](/data/selected_species.csv) | Selected dominant tree species for present study |
| [site_plants_wcvp.csv](/data/site_plants_wcvp.csv) | Recorded plant species from earlier study (Kumar et al., [2023](https://doi.org/10.6084/m9.figshare.23828784.v1)) |
| [site_states.gpkg](/data/site_states.gpkg) | Spatial boundaries of Indian States |
| [species_occ_field.csv](/data/species_occ_field.csv) | Species occurrences from field survey |
| [species_occ_literature.bib](/data/species_occ_literature.bib) | Literature sources for compiling species occurrences |
| [species_occ_literature.csv](/data/species_occ_literature.csv) | Species occurrences compiled from literature sources |
| [wh_bio_2010_current.tif](/data/wh_bio_2010_current.tif) | Current (1981--2010) bioclimatic variables from CHELSA cropped to study area (Karger et al., [2017](https://doi.org/10.1038/sdata.2017.122)) |
| [wh_bio_2040_ssp126.tif](/data/wh_bio_2040_ssp126.tif) | Selected bioclimatic variables for 2011--2040 under SSP1--2.6 scenario from CHELSA cropped to study area |
| [wh_bio_2070_ssp126.tif](/data/wh_bio_2070_ssp126.tif) | Selected bioclimatic variables for 2041--2070 under SSP1--2.6 scenario from CHELSA cropped to study area |
| [wh_bio_2100_ssp126.tif](/data/wh_bio_2100_ssp126.tif) | Selected bioclimatic variables for 2071--2100 under SSP1--2.6 scenario from CHELSA cropped to study area |
| [wh_worldcover_trees.tif](/data/wh_worldcover_trees.tif) | Cropped Tree Cover for study area (Zanaga et al., [2021](https://doi.org/10.5281/zenodo.5571936)) |


## Description of files in [output](/output/) folder derived using `R` 

| Name | Description |  
| :--- | :--- |
| [mod_eval](/output/mod_eval) | Directory with results of model evaluation scores, variable importance and response curves for each species |
| [range_dynamics](/output/range_dynamics) | Directory with results of ensembling modeling (community averaging EMca), species range change (pixel counts), and model agreement scores for each species |
| [0003213-230918134249559.zip](/output/0003213-230918134249559.zip) | Species occurrence dataset downloaded from GBIF ([2023](https://doi.org/10.15468/dl.j7kr5r)) |
| [cleaned_occ.csv](/output/cleaned_occ.csv) | Cleaned and processed species occurrences for selected species used for analysis |
| [mallotus_background.csv](/output/mallotus_background.csv) | Model evaluation results for deciding background points for *Mallotus philippensis* |
| [richness_elevation.csv](/output/richness_elevation.csv) | Elevation of pixels with predicted richness change |
| [species_occ_gbif.csv](/output/species_occ_gbif.csv) | Species occurrence dataset for species from GBIF |
| [suitability_elevation.csv](/output/suitability_elevation.csv) | Elevation of pixels with predicted suitable habitat |
| [wh_elev.tif](/output/wh_elev.tif) | Elevation data used for extracting elevation for pixels |
| [WorldCover_trees_30s.tif](/output/WorldCover_trees_30s.tif) | Tree Cover data downloaded for study area (Zanaga et al., [2021](https://doi.org/10.5281/zenodo.5571936)) |


## Description of `R` scripts

| Name | Description |  
| :--- | :--- |
| [01-make_site_map.R](/R/01-make_site_map.R) | `R` codes to prepare the map for study sites |
| [02-get_gbif_occ.R](/R/02-get_gbif_occ.R)   | `R` codes to retrieve occurrence from GBIF |
| [03-clean_species_occ.R](/R/03-clean_species_occ.R) | `R` codes to clean and process species occurrence |
| [04-decide_background.R](/R/04-decide_background.R) | `R` codes to compare model performance for sampling method and number of background points |
| [05-model_spec_dist.R](/R/05-model_spec_dist.R) | `R` codes to perform MaxEnt modelling for each species |
| [06-get_spec_rich.R](/R/06-get_spec_rich.R) | `R` codes to get elevation for pixels with predicted richness change |
| [07-get_suit_elev.R](/R/07-get_suit_elev.R) | `R` codes to get elevation for pixels with predicted habitat suitability for each species |
| [08-map_range_change.R](/R/08-map_range_change.R) | `R` codes to map pixels with change in habitat suitability for each species |
| [09-plot_elev_density.R](/R/09-plot_elev_density.R) | `R` codes to plot distribution of elevation for habitat suitability of each species |
| [10-plot_hab_suit.R](/R/10-plot_hab_suit.R) | `R` codes to plot habitat suitability for each species |
| [11-plot_resp_curve_single.R](/R/11-plot_resp_curve_single.R) | `R` codes to plot individual response curves for each species and predictor variable |

## Description of other files

| Name | Description |  
| :--- | :--- |
| [ecological-applications.csl](/ecological-applications.csl) | Citation Style Language (CSL) file for [Ecological Applications](https://esajournals.onlinelibrary.wiley.com/journal/19395582) modified from Chicago Manual of Style 17th edition (author-date) citation style |
| [credit_author.csv](/credit_author.csv) | Documentation of each authors' contribution in CRediT (Contributor Roles Taxonomy) author statement |
| [index.qmd](/index.qmd) | Quarto markdown file with embedded `R` codes to reproduce the initial draft of manuscript |
| [odmap_protocol.csv](/odmap_protocol.csv) | Standard ODMAP protocol (Zurell et al. [2020](https://doi.org/10.1111/ecog.04960)) to report the modeling workflow |
| [refs.bib](/refs.bib) | Bibliographic entries for literature cited in the manuscript |
| [shifting-distributions.Rproj](/shifting-distributions.Rproj) | `R` project file |
| [supp_info.qmd](/supp_info.qmd) | Quarto markdown file with embedded `R` codes to reproduce the Supporting Information |

## Codebook for [selected_species.csv](/data/selected_species.csv)

| Column        | Description                                                                    |  
| :------------ | :----------------------------------------------------------------------------- |
| taxon_name    | Accepted botanical name by [POWO](https://powo.science.kew.org/)               |
| taxon_authors | Accepted authorship of botanical name by [POWO](https://powo.science.kew.org/) |
| family        | Accepted family of botanical name by [POWO](https://powo.science.kew.org/)     |
| LL            | Lower limit (LL) of elevational distributions of selected species              |
| UL            | Upper limit (UL) of elevational distributions of selected species              |

## Codebook for [site_plants_wcvp.csv](/data/site_plants_wcvp.csv)

| Column               | Description                                                                    |  
| :------------------- | :----------------------------------------------------------------------------- |
| taxon_name | Accepted botanical names standardised according to World Checklist of Vascular Plants ([WCVP](https://powo.science.kew.org/)) |
| taxon_authors | Accepted authorship of botanical name standardised according to [WCVP](https://powo.science.kew.org/) |
| genus | Accepted botanical genus epithet standardised according to [WCVP](https://powo.science.kew.org/) |
| family | Accepted family of plant species standardised according to [WCVP](https://powo.science.kew.org/), which follows Angiosperm Phylogeny Group (APG) classification |
| powo_dist | Distribution status (Introduced vs. Native) of plant according to [WCVP](https://powo.science.kew.org/) |
| lifeform_description | Lifeform description of selected plant species according to [WCVP](https://powo.science.kew.org/) |
| climate_description | Climate description of selected plant species according to [WCVP](https://powo.science.kew.org/) |
| Morni | Short for Morni Hills |
| Chail | Short for Chail Wildlife Sanctuary |
| Churdhar | Short for Churdhar Wildlife Sanctuary |

## Codebook for species occurrence datasets<sup>a</sup>

<sup>a</sup> [species_occ_field.csv](/data/species_occ_field.csv); [species_occ_literature.csv](/data/species_occ_literature.csv); [cleaned_occ.csv](/output/cleaned_occ.csv); and [species_occ_gbif.csv](/output/species_occ_gbif.csv)

| Column    | Description                                                              |  
| :-------- | :----------------------------------------------------------------------- |
| ID        | ID number in initial species occurrence database                         |
| species   | Name of selected species                                                 |
| longitude | longitude in decimal degrees towards East                                |
| latitude  | latitude in decimal degrees towards North                                |
| reference | citation key for literature source as indicated in [refs.bib](/refs.bib) |
| trees     | Tree cover for each pixel                                  |
| elevation | Elevation in meters for each pixel                                       |
| LL        | Lower elevational limit (in meters) of the species in Himalayas          |
| UL        | Upper elevational limit (in meters) of the species in Himalayas          |


## Codebook for extracted elevation datasets<sup>b</sup>
<sup>b</sup> [richness_elevation.csv](/output/richness_elevation.csv) and [suitability_elevation.csv](/output/suitability_elevation.csv)

| Column    | Description                                        |  
| :-------- | :------------------------------------------------- |
| x         | longitude in decimal degrees towards East          |
| y         | latitude in decimal degrees towards North          |
| species   | Name of selected species                           |
| scen      | Climatic scenarios: current, 2040, 2070, and 2100  |
| richness  | Predicted species richness for each pixel          |
| elevation | Elevation in meters for each pixel                 |


