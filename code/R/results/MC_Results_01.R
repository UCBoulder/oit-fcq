#########################################################################
# Process Anschutz FCQs
# created: Vince Darcangelo 6/1/22
# most recent update: Vince Darcangelo 8/29/24
# \AIM Measurement - Documents\FCQ\R_Code\mc_results\MC_Results_01.R
#########################################################################

library('lubridate')
library('openxlsx')
library('haven')
library('stringr')

# UPDATE THESE VARS EACH SEMESTER:
semester <- 'Fall'
Year <- 2024
term <- 2247
userid <- 'darcange'
filenm <- 'MC_response_export.csv'
folder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - Documents\\FCQ\\')
edb <- read_sas('L:\\datalib\\Employees\\edb\\pers2023.sas7bdat')
dmap <- read_sas('L:\\datalib\\MAP_SIS\\deptmap\\pbadepts.sas7bdat')
#crse_vars dmap will change after transition to R is complete

# set up directory
folder_ex <- paste0(folder, 'CampusLabs\\Response_Exports\\', term)

# check if sub directory exists 
if (file.exists(folder_ex)){
		setwd(folder_ex)
} else {
		dir.create(folder_ex)
		setwd(folder_ex)
}

# move from download to appropriate file
file.rename(from = paste0('C:\\Users\\', userid, '\\OneDrive - UCB-O365\\UCB\\Downloads\\', filenm), to = paste0(folder_ex, '\\', filenm))

###################################################################

drv <- dbDriver('Oracle')
connection_string <- '(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)
  (HOST=ciw.prod.cu.edu)(PORT=1525))(CONNECT_DATA=(SERVICE_NAME=CIW)))'
con <- dbConnect(drv, username = getOption('databaseuid'), 
  password = getOption('databasepword'), dbname = connection_string)

crse_vars <- read.csv(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - Documents\\FCQ\\CourseAudit_bak\\', term, '\\c20.csv'))

##########################################################################
# prepare FCQ result data
##########################################################################
# import response export
mcraw <- read.csv('MC_response_export.csv')
write.xlsx(mcraw, 'MC_response_export_bak.xlsx', showNA = FALSE)

# filter out late drops
mcraw <- mcraw %>%
  filter(Student.Identifier != 'No Identifier Found')

mcdata <- mcraw[,c(1:2, 4:7, 10:11, 13:35)]

mctxt <- mcraw[,c(1:2, 4:7, 10:11, 36:37)]

# rename columns
colnames(mcdata) <- c('CE_Internal_ID', 'Student_Identifier', 'Course_Section_External_ID', 'Course_Section_Label', 'Department', 'Administration_Name', 'Instructor', 'Instructor_External_ID', 'Q01', 'Q02', 'Q03', 'Q04', 'Q05', 'Q06', 'Q07', 'Q08', 'Q09', 'Q10', 'Q11', 'Q12', 'Q13', 'Q14', 'Q15', 'Q16', 'Q17', 'Q18', 'Q19', 'Q20', 'Q21', 'Q22', 'Q23')

colnames(mctxt) <- c('CE_Internal_ID', 'Student_Identifier', 'Course_Section_External_ID', 'Course_Section_Label', 'Department', 'Administration_Name', 'Instructor', 'Instructor_External_ID', 'Comments1', 'Comments2')

# add columns to mcdata
mcdata2 <- mcdata %>%
  mutate(Term = semester) %>%
  mutate(Year = Year) %>%
  mutate(CourseID = str_sub(Course_Section_External_ID,1,-5)) %>%
  mutate(ACAD_ORG_CD = str_sub(Department,-7,-2)) %>%
  mutate(fcqdept = 'MEDS') %>%
  mutate(Coll_cd = case_when(
    ACAD_ORG_CD == 'D-PHSC' ~ 'PHAR',
    TRUE ~ 'MEDS')) %>%
  mutate(College = case_when(
    Coll_cd == 'PHAR' ~ 'School of Pharmacy',
    Coll_cd == 'MEDS' ~ 'School of Medicine')) %>%
  mutate(Dept_cd = ACAD_ORG_CD) %>%
  mutate(Course_Type = str_sub(Course_Section_External_ID,-3,-1)) %>%
  mutate(Course_Display = gsub(':.*','',Course_Section_Label)) %>%
  mutate(Course_Level = 'Graduate')

# create CourseID in crsevars for matching
crse_vars2 <- crse_vars %>%
  mutate(CourseID = paste(TERM_CD, tolower(deptOrgID), tolower(SBJCT_CD), tolower(CATALOG_NBR), tolower(CLASS_SECTION_CD), sep = '_')) %>%
  mutate(Instructor_External_ID = paste0(instrConstituentID, '@cu.edu'))

# join mcdata2 and crse_vars2
mcdata3 <- mcdata2 %>%
  left_join(crse_vars2, by = c( 'CourseID', 'Instructor_External_ID'))

###!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!###
# CHECK # ROWS after join
# if mcdata3 > mcdata2, it's likely due to an instr having 2 instr_Num
comp1 <- mcdata2 %>% select(Course_Section_Label, Instructor) %>% group_by(Course_Section_Label, Instructor) %>% summarize(n())

comp2 <- mcdata3 %>% select(Course_Section_Label, Instructor, instrNum) %>% group_by(Course_Section_Label, Instructor) %>% summarize(n())

# identify differences
comp3 <- anti_join(comp2,comp1)

# find cause
comp4 <- comp3 %>%
  select(Course_Section_Label, Instructor) %>%
  left_join(mcdata3)

# remove dup instrNum for anti_join
comp5 <- comp4 %>%
  filter(instrNum == max(instrNum))

# remove dup instrNum
mcdata3 <- mcdata3 %>%
  anti_join(comp5)
#########################################################################

# add course_code
mcdata3 <- mcdata3 %>%
  mutate(Course_Code = paste0(SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD))

# replace 0 & 6 with NA for calculations
mcdata3[, 9:31][mcdata3[, 9:31] == 0] <- NA
mcdata3[, 9:31][mcdata3[, 9:31] == 6] <- NA

# export files to working directory
write.csv(mcdata3, 'MC_Final_R.csv', row.names = FALSE)
write.csv(mctxt, 'MC_Text_R.csv', row.names = FALSE)

##################################################################
# create match table for batch processing
mc_batch_match <- mcdata2 %>%
  distinct(Instructor_External_ID, Instructor, ACAD_ORG_CD)

# export instr table to csv
write.csv(mc_batch_match, 'MC_Inst_Batch.csv', row.names = FALSE)

##################################################################
# create summaries

# for tableau
mc_tab <- mcdata3 %>%
  select(Term, Year, Course_Section_External_ID, Course_Section_Label, fcqdept.x, Coll_cd, College, Dept_cd, Department, SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, CRSE_LD,  Course_Display, Course_Level, Course_Type, Course_Code, Administration_Name, instrNm, totEnrl_nowd_comb, Q01, Q02, Q03, Q04, Q05, Q06, Q07, Q08, Q09, Q10, Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18, Q19, Q20, Q21, Q22, Q23) %>%
  mutate(across(Q01:Q23, ~replace(.x, is.nan(.x), '')))

colnames(mc_tab) <- c('Term', 'Year', 'Course_Section_External_ID', 'Course_Section_Label', 'fcqdept', 'Coll_cd', 'College', 'Dept_cd', 'Department', 'Subject', 'Course', 'Section', 'Course_Title', 'Course_Display', 'Course_Level', 'Course_Type', 'Course_Code', 'Administration_Name', 'Instructor', 'Enrollment', 'Q01', 'Q02', 'Q03', 'Q04', 'Q05', 'Q06', 'Q07', 'Q08', 'Q09', 'Q10', 'Q11', 'Q12', 'Q13', 'Q14', 'Q15', 'Q16', 'Q17', 'Q18', 'Q19', 'Q20', 'Q21', 'Q22', 'Q23')

# export master update
write.csv(mc_tab, 'MC_Tableau_master_update.csv', row.names = FALSE)

# for Excel instructor summary
mc_summ <- mc_tab %>%
  select('Term', 'Year', 'Course_Code', 'College', 'Department', 'Subject', 'Course', 'Section', 'Course_Title', 'Instructor', 'Enrollment', 'Q01', 'Q02', 'Q03', 'Q04', 'Q05', 'Q06', 'Q07', 'Q08', 'Q09', 'Q10', 'Q11', 'Q12', 'Q13', 'Q14', 'Q15', 'Q16', 'Q17', 'Q18', 'Q19', 'Q20', 'Q21', 'Q22', 'Q23')

# create mc_grpd for class summaries
mc_grpd <- mc_summ %>%
  mutate(across(Q01:Q23, as.numeric, na.rm = TRUE)) %>%
  group_by(across(c(Term, Year, Course_Code, College, Department, Subject, Course, Section, Course_Title, Instructor, Enrollment))) %>%
  summarise(across(Q01:Q23, mean, na.rm = TRUE), responses = n()) %>%
  mutate(across(Q01:Q23, round, 1)) %>%
  relocate(responses, .before = Q01)

# create Response_Rate column
mc_grpd2 <- mc_grpd %>%
  mutate(rr = responses/Enrollment)

# format percentages
mc_grpd2$Response_Rate <- scales::percent(mc_grpd2$rr, digits = 1)

# arrange columns
mc_grpd3 <- mc_grpd2 %>%
  select(-rr) %>%
  relocate(Response_Rate, .before = Q01)

mc_update <- mc_grpd3 %>%
  ungroup() %>%
  select(-Course_Code) %>%
  arrange(Year)

mc_update2 <- as.data.frame(mc_update)

mc_update2 <- mc_update %>%
  mutate(across(Q01:Q23, round, 1)) %>%
  mutate(across(Q01:Q23, ~replace(.x, is.nan(.x), '')))

colnames(mc_update2) <- c('Term', 'Year', 'College', 'Department', 'Subject', 'Course', 'Section', 'Course_Title', 'Instructor', 'Enrollment', 'Responses', 'Response_Rate', 'Syllabus', 'Assignments', 'Feedback', 'Stu_Engage', 'Grade_Criteria', 'Availability', 'Flexibility', 'Organized', 'Stu_Interaction', 'Express_Concerns', 'Real_World', 'Collaborate', 'Teamwork', 'Stu_Contribute', 'Critical_Thinking', 'Revisions', 'Inst_Effect', 'Crse_Effect', 'Challenge', 'New_Info', 'Crse_Content', 'Learning_Needs', 'Technology')

# export for instr summ update
write.csv(mc_update2, 'MC_instr_summ_update.csv', row.names = FALSE)
