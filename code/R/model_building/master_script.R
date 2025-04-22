### Project: repo-name-year <https://github.com/UCBoulder/link-to-repo-here

### Runs the pipeline scripts

source(paste0(path, "code/R/model_building/1_load.R"))
source(paste0(path, "code/R/model_building/2_clean.R"))
source(paste0(path, "code/R/model_building/3_model.R"))
source(paste0(path, "code/R/model_building/4_test.R"))

