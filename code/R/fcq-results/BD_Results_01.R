#########################################################################
# Process Boulder FCQs
# created: Vince Darcangelo 10/20/21
# most recent update: Vince Darcangelo 8/28/25
# \OneDrive - UCB-O365\Documents\oit-fcq\code\R\fcq-results\BD_Results_01.R
#########################################################################

library('lubridate')
library('openxlsx')
library('haven')
library('stringr')

# UPDATE THESE VARS EACH SEMESTER:
Year <- 2025
term_scores <- 2254
userid <- 'darcange'
filenm <- 'BD_response_export.csv'
folder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\')
edb <- read_sas('L:\\datalib\\Employees\\edb\\pers2023.sas7bdat')
dmap <- read_sas('L:\\datalib\\MAP_SIS\\deptmap\\pbadepts.sas7bdat')

# set sem147 var (term number) based on 1 = spring, 4 = summer, 7 = fall
if (grepl('1$', term_scores)) {
  sem147 <- 1
} else if (grepl('4$', term_scores)) {
  sem147 <- 4
} else if (grepl('7$', term_scores)) {
  sem147 <- 7
}

# set semester, begin and end date vars based on sem147
if (sem147 == 1) {
  sem <- 'Spring'
} else if (sem147 == 4) {
  sem <- 'Summer'
} else if (sem147 == 7) {
  sem <- 'Fall'
}

# set up directory
folder_ex <- paste0(folder, 'CampusLabs\\Response_Exports\\', term_scores)

# check if sub directory exists 
if (file.exists(folder_ex)){
		setwd(folder_ex)
} else {
		dir.create(folder_ex)
		setwd(folder_ex)
}

#########################################################################

drv <- dbDriver('Oracle')
connection_string <- '(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)
  (HOST=ciw.prod.cu.edu)(PORT=1525))(CONNECT_DATA=(SERVICE_NAME=CIW)))'
con <- dbConnect(drv, username = getOption('databaseuid'), 
  password = getOption('databasepword'), dbname = connection_string)

#########################################################################
# prepare crse_vars
#########################################################################
# import crse_vars file
crse_vars <- read.csv(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CourseAudit_bak\\', term_scores, '\\c20.csv'))

# create CourseID in crsevars for matching
crse_vars2 <- crse_vars %>%
  mutate(CourseID = paste(TERM_CD, tolower(deptOrgID), tolower(SBJCT_CD), tolower(CATALOG_NBR), tolower(CLASS_SECTION_CD), sep = '_')) %>%
  mutate(Course_Section_External_ID = paste(TERM_CD, tolower(deptOrgID), tolower(SBJCT_CD), tolower(CATALOG_NBR), tolower(CLASS_SECTION_CD), tolower(SSR_COMP_CD), sep = '_')) %>%
  mutate(Instructor_External_ID = paste0(instrConstituentID, '@cu.edu'))

#########################################################################
# prepare FCQ result data
#########################################################################
# import response export file
bdraw <- read.csv('BD_response_export.csv')

# filter out late drops (e.g., Student.Identifier == 'No Identifier Found')
bdraw2 <- bdraw %>%
  filter(Student.Identifier != 'No Identifier Found')

# create xlsx back up
write.xlsx(bdraw2, 'BD_response_export_bak.xlsx', showNA = FALSE)

# create data file for Tableau/Excel reports
bddata <- bdraw2[,c(1:2, 4:7, 10:11, 13:28)]

# create data file for text analysis
bdtxt <- bdraw2[,c(1:2, 4:7, 10:11, 29)]

# rename columns
colnames(bddata) <- c('CE_Internal_ID', 'Student_Identifier', 'Course_Section_External_ID', 'Course_Section_Label', 'Department', 'Administration_Name', 'Instructor', 'Instructor_External_ID', 'Q01', 'Q02', 'Q03', 'Q04', 'Q05', 'Q06', 'Q07', 'Q08', 'Q09', 'Q10', 'Q11', 'Q12', 'Q13', 'Q14', 'Q15', 'Q16')

colnames(bdtxt) <- c('CE_Internal_ID', 'Student_Identifier', 'Course_Section_External_ID', 'Course_Section_Label', 'Department', 'Administration_Name', 'Instructor', 'Instructor_External_ID', 'Comments')

# separate course/instr items
bddata_crse <- bddata %>%
  filter(Instructor_External_ID == 'Course Section Results') %>%
  mutate(Key = paste(CE_Internal_ID, Course_Section_External_ID, sep = '_')) %>%
  select(-c(Instructor, Instructor_External_ID, Q09, Q10, Q11, Q12, Q13, Q14, Q15, Q16))

bddata_inst <- bddata %>%
  filter(Instructor_External_ID != 'Course Section Results') %>%
  mutate(Key = paste(CE_Internal_ID, Course_Section_External_ID, sep = '_')) %>%
  select(Key, Course_Section_External_ID, Course_Section_Label, Instructor, Instructor_External_ID, Q09, Q10, Q11, Q12, Q13, Q14, Q15, Q16)

# create instructor table to fill missing IDs at the end of process
bd_inst_table <- bddata_inst %>%
  distinct(Course_Section_External_ID, Instructor, Instructor_External_ID)

# export instr table to csv
write.csv(bd_inst_table, 'BD_Inst_Table.csv', row.names = FALSE)

bdtxt2 <- bdtxt %>%
  filter(Instructor_External_ID != 'Course Section Results' & Comments != '') %>%
  mutate(Key = paste(CE_Internal_ID, Course_Section_External_ID, sep = '_'))

# remove Course_Section_Label from bddata_inst
bddata_inst <- bddata_inst %>%
  select(-c(Course_Section_External_ID, Course_Section_Label))

#########################################################################
# QC: look for missing instr IDs
inst_miss_a <- bddata_inst %>%
  filter(is.na(Instructor_External_ID))

inst_miss_b <- bddata_inst %>%
  filter(Instructor_External_ID == '')

inst_miss <- rbind(inst_miss_a, inst_miss_b)

if(nrow(inst_miss) == 0) {
    print('no missing IDs')
  } else {
    View(inst_miss)
    stop('Review and fix missing instr IDs (inst_miss) before continuing')
}

#########################################################################

# combine course and instructor response rows
bd_comb <- merge(x = bddata_crse, y = bddata_inst, by = 'Key', all.x = TRUE)
bd_comb <- bd_comb %>%
  relocate(c(Instructor, Instructor_External_ID), .before = Q01)

# separate blank instructor rows (stu completed 1+ crse q, but no instr q)
bd_comb_missing <- bd_comb %>%
  filter(is.na(Instructor)) %>%
  select(-c(Instructor, Instructor_External_ID))

# remove blank instructor rows from bd_comb
bd_comb0 <- bd_comb %>%
  filter(!is.na(Instructor))

# fill missing values
bd_filled <- merge(bd_comb_missing, bd_inst_table, by = 'Course_Section_External_ID', all.x = TRUE) %>%
#  select(-c(assoc_class_secID, spons_id)) %>%
  relocate(Course_Section_External_ID, .after = Student_Identifier) %>%
  relocate(c(Instructor, Instructor_External_ID), .before = Q01)

#########################################################################
# QC: look for NAs created by no students filling out inst questions
bd_filledx <- bd_filled %>%
  filter(is.na(Instructor)) %>%
  select(-c(Instructor, Instructor_External_ID))

# create inst table with just name and ID
bd_inst_table2 <- bd_inst_table %>%
  select(Instructor, Instructor_External_ID)

# create crse_vars table matching information
crse_vars3 <- crse_vars2 %>%
  select(Instructor_External_ID, Course_Section_External_ID, instrFirstNm, instrLastNm) %>%
  mutate(Instructor = paste(instrFirstNm, instrLastNm, by = ' ')) %>%
  select(-c(instrFirstNm, instrLastNm)) %>%
  distinct()

# match to fill missing info
bd_filledx2 <- bd_filledx %>%
  left_join(crse_vars3, 'Course_Section_External_ID') %>%
  relocate(c(Instructor, Instructor_External_ID), .before = Q01)

# prep bd_filled to recombine with fixed rows
bd_filled0 <- bd_filled %>%
  filter(!(is.na(Instructor)))

# recombine fixed rows
bd_filled_comb <- rbind(bd_filled0, bd_filledx2)

#########################################################################
# QC: check that number of output rows matches bd_comb_missing
bd_filled2 <- bd_filled_comb %>%
  mutate(paired = paste0(Student_Identifier, '_', Course_Section_External_ID)) %>%
  distinct(paired)

if(nrow(bd_filled2) == nrow(bd_comb_missing)) {
    print('bd_filled2 and bd_comb_missing have equal rows')
  } else {
    stop('bd_filled2 and bd_comb_missing have different outputs')
}

# fill bd_comb0 file
#bd_comb1 <- left_join(bd_comb0, bd_inst_table, by = c('Course_Section_External_ID', 'Instructor_External_ID', 'Instructor'))

#bd_comb2 <- bd_comb1 %>%
#  relocate(c(Instructor, Instructor_External_ID), .before = Q01)

bd_comb3 <- rbind(bd_comb0, bd_filled_comb)

########################################################################
# create other vars
##########################################################################

bd_complete <- left_join(bd_comb3, crse_vars2, by = c( 'Course_Section_External_ID', 'Instructor_External_ID'), suffix = c('','.y')) %>%
  select(-ends_with('.y'))

# create other vars
bd_complete2 <- bd_complete %>%
  mutate(Semester = sem) %>%
  mutate(Year = Year) %>%
  mutate(Course_Level = case_when(
    CATALOG_NBR >= 5000 ~ 'Graduate',
    CATALOG_NBR >= 3000 ~ 'Upper',
    CATALOG_NBR <= 2999 ~ 'Lower'))

# replace 0 with NA for calculations
bd_complete2[, 10:25][bd_complete2[, 10:25] == 0] <- NA

#########################################################################
# create match table for batch processing
bd_batch_match <- bd_complete2 %>%
  distinct(Instructor_External_ID, Instructor, fcqdept, ACAD_ORG_CD, SBJCT_CD)

# export instr table to csv
write.csv(bd_batch_match, 'BD_Inst_Batch.csv', row.names = FALSE)
#########################################################################

# create new vars for later use
bd_complete3 <- bd_complete2 %>%
  mutate(PBADeptCode = substr(ACAD_ORG_CD, 3, 6))

dmap2 <- dmap %>%
  select(c(PBADeptCode, ASCluster)) %>%
  mutate(ASCluster = case_when(
    PBADeptCode == 'ARSP' ~ 'Arts & Humanities',
    ASCluster == 'AH' ~ 'Arts & Humanities',
    ASCluster == 'NS' ~ 'Natural Sciences',
    ASCluster == 'SS' ~ 'Social Sciences',
    TRUE ~ 'Not in A&S'))

# at this step, check for ARSC
bd_master_update0 <- left_join(bd_complete3, dmap2, by = 'PBADeptCode')

bd_master_update0 <- bd_master_update0 %>%
  mutate(ASCluster = case_when(
    is.na(ASCluster) ~ 'Not in A&S',
    TRUE ~ ASCluster
  ))

instdemo <- edb %>%
  select(c(EID, EMPLOYEE_CONSTITUENT_ID, Name, Gender, EthnicRaw, JobTitle, Tenured, TTT, YearsInPosition, BirthDate)) %>%
  mutate(EthnicRaw = as.character(EthnicRaw)) %>%
  mutate(EID = as.integer(EID)) %>%
  mutate(instEthn = case_when(
    str_starts(EthnicRaw, 'VI') ~ 'Unknown',
    EthnicRaw == 'NSPEC' ~ 'Unknown',
    EthnicRaw == '' ~ 'Unknown',
    TRUE ~ EthnicRaw)) %>%
  mutate(instTitle = case_when(
    JobTitle %in% c('PROFESSOR', 'ASST PROFESSOR', 'ASSOCIATE PROFESSOR') ~ 'Tenured, Tenure-Track',
    JobTitle %in% c('INSTRUCTOR', 'SENIOR INSTRUCTOR') ~ 'Instructor',
    JobTitle == 'TEACHING ASSISTANT' ~ 'Teaching Assistant',
    TRUE ~ 'Other')) %>%
  mutate(instConID = paste0(EMPLOYEE_CONSTITUENT_ID, '@cu.edu')) %>%
  mutate(instName = gsub(',' , ', ' , Name)) %>%
  mutate(instAge = as.period(interval(start = BirthDate, end = today()))$year) %>%
  select(c(EID, EMPLOYEE_CONSTITUENT_ID, instConID, instName, Gender, instEthn, instTitle, Tenured, TTT, YearsInPosition, instAge))

# rename columns
colnames(instdemo) <- c('instEID', 'instConID_raw', 'instrConID', 'instName', 'instGen', 'instEthn', 'instTitle', 'instTenured', 'instTTT', 'instYIP', 'instAge')

# combine bd_master_update0 with instdemo
bd_crse_inst <- left_join(bd_master_update0, instdemo, by = c('instrEmplid' = 'instEID'))

bd_crse_inst2 <- bd_crse_inst %>% 
  mutate(instTitle = case_when(is.na(instTitle) ~ 'Other', TRUE ~ instTitle)) %>%
  mutate(instMode = case_when(
    INSTRCTN_MODE_CD == 'HY' ~ 'Hybrid (In Person & Online/Remote)',
    INSTRCTN_MODE_CD == 'P' ~ 'In Person',
    INSTRCTN_MODE_CD %in% c('R', 'OL', 'HR', 'OS') ~ 'Online & Remote'
  )) %>%
  mutate(INSTRCTN_MODE_CD = case_when(
    INSTRCTN_MODE_CD == 'HY' ~ 'Hybrid In Person & Online/Remote',
    INSTRCTN_MODE_CD == 'P' ~ 'In Person',
    INSTRCTN_MODE_CD == 'R' ~ 'Remote',
    INSTRCTN_MODE_CD == 'OL' ~ 'Online',
    INSTRCTN_MODE_CD == 'HR' ~ 'Hybrid Remote/Online',
    INSTRCTN_MODE_CD == 'OS' ~ 'Online Flex'
  )) %>%
  mutate(CLASS_TYPE = case_when(
    CLASS_TYPE == 'E' ~ 'Primary (e.g., lecture)',
    CLASS_TYPE == 'N' ~ 'Non-Primary (e.g., recitation)'
  )) %>%
  mutate(Course_Display = paste0(SBJCT_CD, ' ', CATALOG_NBR, '(', CLASS_SECTION_CD, ')')
  ) %>%
  mutate(Course_Code = paste0(SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD)
  ) %>%
  mutate(dMatch = paste0(Year, Semester, Course_Code)
  ) %>%
  mutate(Class_Size = case_when(
    totEnrl_nowd_comb < 25 ~ 'Less than 25',
    totEnrl_nowd_comb >= 25 & totEnrl_nowd_comb <= 75 ~ '25-75 students',
    totEnrl_nowd_comb > 75 ~ 'More than 75'
  )) %>%
  mutate(as.character(CLASS_SECTION_CD))
  
##########################################################################
# create summaries
##########################################################################
# tableau summary
bd_tab <- bd_crse_inst2 %>%
  select(c(Semester, Year, CE_Internal_ID, Course_Section_External_ID, Course_Section_Label, TERM_CD, campus, fcqdept, PBADeptCode, ACAD_GRP_CD, ACAD_GRP_LD, ASCluster, ACAD_ORG_CD, ACAD_ORG_LD, Department, SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, crseSec_comp_cd, INSTRCTN_MODE_CD, instMode, CLASS_TYPE, CRSE_LD, Course_Display, Course_Level, Course_Code, Administration_Name, instrNm, instTitle, Instructor_External_ID, totEnrl_nowd_comb, Class_Size, Q01, Q02, Q03, Q04, Q05, Q06, Q07, Q08, Q09, Q10, Q11, Q12, Q13, Q14, Q15, Q16)) %>%
  mutate(campus = case_when(
    campus == 'BD' ~ 'Boulder Main Campus',
    campus == 'CE' ~ 'Boulder Continuing Education',
    campus == 'B3' ~ 'B3'
  ))

# export bd_tab to csv
write.csv(bd_tab, 'BD_Tableau_master_update.csv', row.names = FALSE)

# registrar viz summary
bd_reg <- bd_crse_inst2 %>%
  select(c(Semester, Year, campus, ACAD_GRP_LD, Course_Level, Department, ASCluster, SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, Course_Section_Label, instrNm, instConID_raw, instTitle, crseSec_comp_cd, totEnrl_nowd_comb, CRSE_LD, Q01, Q02, Q03, Q04, Q05, Q06, Q07, Q08, Q09, Q10, Q11, Q12, Q13, Q14, Q15, Q16))

bd_reg <- bd_reg %>%
  mutate(dMatch = paste0(Year, Semester, SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD)) %>%
  relocate(dMatch, .after = instTitle)

# export bd_reg to csv
write.csv(bd_reg, 'BD_Reg20_master_update.csv', row.names = FALSE)

# create bd_grpd for class summaries
bd_grpd <- bd_crse_inst2 %>%
  group_by(across(c(Semester, Year, campus, ACAD_GRP_CD, fcqdept, SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, CRSE_LD, instrNm, instTitle, crseSec_comp_cd, Course_Level, totEnrl_nowd_comb))) %>%
  summarise(across(Q01:Q16, mean, na.rm = TRUE), responses = n()) %>%
  mutate(across(Q01:Q16, round, 1)) %>%
  mutate(across(Q01:Q16, ~replace(.x, is.nan(.x), ''))) %>%
  relocate(responses, .before = Q01)

# create Response_Rate column
bd_grpd2 <- bd_grpd %>%
  mutate(rr = responses/totEnrl_nowd_comb)

# format percentages
bd_grpd2$Response_Rate <- scales::percent(bd_grpd2$rr, digits = 1)

# excel instr summary
bd_sum <- bd_grpd2 %>%
  select(-rr) %>%
  relocate(Response_Rate, .before = Q01) %>%
  mutate(Term_cd = term_scores)

# export bd_sum to csv
write.csv(bd_sum, 'BD_Instr_Summary_update.csv', row.names = FALSE)