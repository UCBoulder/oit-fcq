### Project: repo-name-year <https://github.com/UCBoulder/link-to-repo-here

### Runs the pipeline scripts

source(paste0(path, "code/R/prediction_pipeline/1_load.R"))
source(paste0(path, "code/R/prediction_pipeline/2_clean.R"))
source(paste0(path, "code/R/prediction_pipeline/3_predict.R"))

