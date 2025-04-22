# oit-fcq

## Purpose:

This repo contains various code scripts that we use for FCQs. This does not include the course audit or NLP scripts. For those, please see their dedicated repositories: oit-an-course-audit and oit-an-nlp 

Current packages:

tidyverse, tidymodels, caret, arrow, and readxl R packages. 

## Requirements

*State data, access, and/or software needed to run this repo, and, if applicable, how to acquire these requirements.*

## How To Run:

*Describe how to:*

  - *run the production pipeline to generate predictions*
  - *view the model evaluations and predictions*
  - *train and re-create the model and evaluations from the raw data.*

To use this repo template:
- Create a repo with this oda-ds-template as a template in a web browser, naming your new project in the form: "project-name-YEAR"
- Clone that repo (locally or in Workbench). 
- If using R, create an R Project in this new repo directory. 
- Create and restore virtual environment
  - If using R: Run renv::restore(lockfile = "renv.lock"), typing 'Y' to the prompts asking if you'd like to activate and install these packages.
  - If using Python: proceed with restoring the Python virtual environment from the py.lock file. 
- Delete the this and italicized text, and fill in this Readme with your project specific info. 
- Make an awesome project!

To add additional commonly used packages to this template renv.lock file:

- Clone the template repo, make it a project, run renv::restore() as above.
- Run renv::install("package_name") to install the packages you'd like to have permanently stored in this template.
- Run renv::snapshot(type = "all") to update the renv.lock file with the newly installed packages.
- Add, commit, and push these changes to the DS-template-2023 repo. 

## Output

*Describe the output of this repo's final pipeline.*

## Notes

*Any additional notes or background information that could be useful.*

More info on virtual environments:

https://cu-oda.atlassian.net/wiki/spaces/AET/pages/1766326576/Virtual+Environments

More info on DS Team practices:

https://cu-oda.atlassian.net/wiki/spaces/DST/pages/1745715201/Data+Science+Team+Processes

## Repo Structure

*Maybe this is too much and unnecessary?*

project-name-year <—– Top level folder name.
- 📄 .gitignore <—– Keep data, secrets, and other files out of version control.
- 📄 README.md <—– Documentation for your Github repo.
- 📂 code <—– All analytic code goes under here. 
  - 📂 SQL <—– Raw SQL files used to pull data.
  - 📂 Python
    - 📄 0_config_utils_functions.py <—– Path variable and all custom functions used in Python directory.
    - 📂 exploratory_sandbox <—– Sandbox for experimentation and exploration: EDA, general analysis, model training attempts. 
      - 📄 1_load.py <—– Load data, libraries, packages, macros, methods.
      - 📄 2_clean.py <—– Cleaning to turn a raw data set into an analytic data set.
    - 📂 model_building <—– Pipeline that trains the final model.
      - 📄 1_load.py <—– Load data, libraries, packages, macros, methods.
      - 📄 2_clean.py <—– Cleaning to turn a raw data set into an analytic data set.
      - 📄 3_model.py <—– Model training pipeline.
      - 📄 4_test.py <—– Model test on out of sample data.
      - 📄 master_script.py <—– Simple script that runs/sources the other scripts in this directory.
    - 📂 prediction_pipeline <—– Pipeline that is put into production and generates a product (change name if not predictions).
      - 📄 1_load.py <—– Load data, libraries, packages, macros, methods.
      - 📄 2_clean.py <—– Cleaning to turn a raw data set into an analytic data set.
      - 📄 3_predict.py <—– Model training pipeline.
      - 📄 master_script.py <—– Simple script that runs/sources the other scripts in this directory.
  - 📂 R
    - 📄 0_config_utils_functions.R <—– Path variable and all custom functions used in R directory.
    - 📂 exploratory_sandbox <—– Sandbox for experimentation and exploration: EDA, general analysis, model training attempts.
      - 📄 1_load.R <—– Load data, libraries, packages, macros, methods.
      - 📄 2_clean.R <—– Cleaning to turn a raw data set into an analytic data set.
      - 📄 sandbox.Rmd <—– Explore and write code in a notebook if you prefer as an alternative to script based EDA. 
    - 📂 model_building <—– Pipeline that trains the final model.
      - 📄 1_load.R <—– Load data, libraries, packages, macros, methods.
      - 📄 2_clean.R <—– Cleaning to turn a raw data set into an analytic data set.
      - 📄 3_model.R <—– Model training pipeline.
      - 📄 4_test.R <—– Model test on out of sample data.
      - 📄 master_script.R <—– Simple script that runs/sources the other scripts in this directory.
    - 📂 prediction_pipeline <—– Pipeline that is put into production and generates a product (change name if not predictions).
      - 📄 1_load.R <—– Load data, libraries, packages, macros, methods.
      - 📄 2_clean.R <—– Cleaning to turn a raw data set into an analytic data set.
      - 📄 3_predict.R <—– Model training pipeline.
      - 📄 master_script.R <—– Simple script that runs/sources the other scripts in this directory.
- 📂 data <—– Top level for all data. Be sure to add to your .gitignore
  - 📂 final <—– Files are fully ready for ML models or distributed out products
  - 📂 raw <—– Raw data. Put them here, then leave them alone. Forever.
  - 📂 transformed <—– Saved data files after cleaning and transforms, but before ready for full deployment
- 📂 output <—– Top level file for the various project outputs, artifacts, presentations
  - 📂 pres_reports <—– Powerpoint, PDF, HTML and similar reports go here, including Rmd's that knit to ppt
  - 📂 viz_files <—– Saved versions of stable viz files for use in other reports, PowerPoints or emailing
    - 📄 template.pptx <—– Blank Powerpoint file that needs to be in the same directory as an .Rmd to serve as a template for formatting.
- 📂 saved_models <—– Top level folder for models. Store in-progress or model attempts outside final directory.
  - 📂 final <—– Final model that is ready for deployment or production. If there are multiple models here, consider making another repo.
