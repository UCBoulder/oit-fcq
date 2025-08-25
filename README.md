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
  - add CIW credentials and clear console afterward
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
  
  - newSemCalendar.R
    - This generates the code to update in FCQ_audit03.R
    - Follow instructions for set up (has a manual component)

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

  - fcq_Comm_Docs.Rmd
    - This updates the memos we send to FCQ coordinators each semester
      - update the term_cd variable and then save
      - don't need to run, but can if you want to

  - fcq_Comm_Render.R
    - Generates the Word file with all the memos
      - only run after fcq_Comm_Docs.Rmd has been updated and saved
      - update the term_cd variable and then run
      - Word doc is generated in the oit-fcq/outputs folder

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
 
## Processes

**Setting up a new semester**
- Go to account-mgmt
  - run CL_New_Sem_Setup.R
    - import AcademicTerm files from CL_New_Sem_Setup.R to Anthology
    - create folders and files for new term
    - create communication schedule and docs
  - run newSemCalendar.R
    - use output to set session dates in FCQ_Audit03.R
    - use academic calendars from each campus Registrar to set final admins
      - summer session does not get final admin, only spring/fall
      - exceptions to look out for:
        - DN-Beijing: decides each semester whether or not to use FCQs
        - BD-ENGR: some classes get extended admin in fall/spring
        - BD-LAWS: usually wants early final admin in fall/spring
    - update calendar on FCQ website, www.colorado.edu/fcq
  - run CL_Dept_Create.R to add new departments/subjects
    - import OrgUnit files from CL_Dept_Create.R to Anthology

## Notes

