## Purpose:

This repo contains the core code scripts that we use for FCQs. This does not include the NLP scripts, which have their own dedicated repository: oit-an-fcq-nlp.

They are organized in four folders in the Home > oit-fcq > code > R directory.

**account-mgmt**: Account management files
Use these scripts when there is a change between what is in CU-SIS and the FCQ platform or when setting up a new semester.

**course-audit**: Course audit files
Use these scripts to pull CIW data, clean and evaluate for FCQ purposes, and generate course audit files for public use. Run once per week (usually on Friday) and use the output to set up the next FCQ session. Run daily during the course audit windows (March, June, October).

**create-sessions**: Create session files
Run in conjunction with the course audit files to set up weekly and final FCQ administrations. CL_Imports.R is the primary file. The others are special circumstances.

**data-mgmt**: Data management files
These are for reference and historical records purposes.

**fcq-results**: Results files
Use these files to process FCQ results at the end of each semester.

## Requirements

  - run Install_Packages.R
  - run Load_Libraries.R
  - run CIW credentials and clear console afterward
    - options(database_userid = "CIWID")
    - options(database_password = "CIWPASSWORD")

## Files:

**account-mgmt**
Run when a change is made to an account (only as needed).

  - CL_Acct_Create.R
    - Use this to add someone to Campus Labs/Anthology
    - e.g., a new hire takes over as report administrator for their dept

  - CL_Dept_Create.R
    - Use this when a new department is created and needs to be setup for FCQs
  
  - CL_New_Sem_Setup.R
    - Run this in advance of an upcoming semester
    - It creates folders for Campus Labs/Anthology imports (weekly admins)
    - It creates cumulative files to compile all semester data
    - It creates the backup folder for all course audits
  
  - InstCL_batch.R
    - Compiles a log of all classes evaluated for an instructor
    - **very** seldom do we use this
  
  - InstCL_change.R
    - This accounts for instructor changes in the permanent record
    - This is very important for results processing and billing
    - e.g., adding or removing an instructor or swapping instructors
  
  - stuenrlWithdraws.R
    - Run at the end of each semester to pickup late drops/withdrawals
    - Generates a file that is imported to Campus Labs/Anthology

**course-audit**
Run weekly throughout the semester (usually on Fridays), and run daily during the course audit period.

  - FCQ_Audit01.R
    - Pulls, cleans and preps CIW data for FCQ setup
    - Code is static - only change when needed
  
  - FCQ_Audit02.R
    - Creates columns to calculate which classes are eligible for FCQs
    - Code is static - only change when needed
  
  - FCQ_Audit03.R
    - Calculates eligibility, applies FCQ run dates and formats for audit
    - Code is dynamic - must be updated each semester and tweaked whenever changes are requested or custom questions are updated

  - FCQ_Audit04.R
    - Generates the course audit files
    - Code is static - only change when needed

**create-sessions**
Schedule varies, so run as indicated below.

  - CL_Imports_stu_enrl.R
    - Creates import file for late additions to class roster
    - Only use this file if:
      - class has already been setup in Campus Labs/Anthology
      - student is not already in Campus Labs/Anthology system
  
  - CL_Imports.R
    - Creates the import/backup files for each FCQ administration
    - This gets run once per week during Fall/Spring outside of final administration and all of Summer
    - Final administrations take longer to setup, so allow a few days (even a week) to set those up
    - Adjust the "session" variable as needed
  
  - emCheck1.R
    - Don't use this file directly - it is opened by CL_Imports.R when needed
    - This alerts us when an instructor doesn't have an email/account
      - update code anytime this file is opened by CL_Imports.R

  - emCheck2.R
    - Don't use this file directly - it is opened by CL_Imports.R when needed
    - This alerts us when a student doesn't have an email/account
      - update code anytime this file is opened by CL_Imports.R

  - splitEnrlCL.R
    - The Campus Labs/Anthology interface has a size restriction
    - Only use this file twice per year - when processing final BD and final DN administrations for the Fall/Spring semesters
    - It splits the stuEnrl file into chunks that fall under the size restriction
      - CE and MC don't have enough students to require this
      - weekly administrations don't have enough students to require this

**data-mgmt**
Reference files. Only run as needed.

  - CL_Data_Dictionary.R
    - Pulls all variable names from the CIW data tables we use
    - Purpose is to make it easier to review available variables
  
  - crse_vars_process.R
    - Cleans up late changes to courses/instructors each semester
    - Keeps the historical record up to date
    - Only run as needed

  - custQ_parse.R
    - Compiles a list of all active custom questions
    - Don't need to run very often - only as needed

**fcq-results**
Processes FCQ results at the end of each semester.

  - (BD/DN/MC)_Batch_Process.R
    - Extracts the zip files from Campus Labs/Anthology
    - Sorts by department and exports zips into Batch Reports folder
  
  - (BD/DN/MC)_Results_01.R
    - Cleans and preps raw results file (provided by Campus Labs/Anthology)
    - Combines with CIW information for more robust data
    - Generates files to append to Tableau and spreadsheet summaries

  - (BD/DN/MC)_TextMining.R
    - Isolates student comments column(s) and cleans up formatting
    - Creates and exports raw text file to use with NLP
    - Uses keyword search to flag comments for review (used for crisis review)

  - (bd/dn/mc)Text2Word.Rmd
    - Converts flagged comments spreadsheet to Word document for readability
    - Use this document to search for crisis flags
  
  - CL_batch_compilation.R
    - Maps the contents of the Batch Reports folders for reference
    - Only run as needed
 
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
