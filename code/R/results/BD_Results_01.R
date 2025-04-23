#########################################################################
# Process Boulder FCQs
# created: Vince Darcangelo 10/20/21
# most recent update: Vince Darcangelo 8/29/24
# \AIM Measurement - Documents\FCQ\R_Code\bd_results\BD_Results_01.R
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
filenm <- 'BD_response_export.csv'
folder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - Documents\\FCQ\\')
edb <- read_sas('L:\\datalib\\Employees\\edb\\pers2022.sas7bdat')
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
crse_vars <- read.csv(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - Documents\\FCQ\\CourseAudit_bak\\', term, '\\c20.csv'))

# create CourseID in crsevars for matching
crse_vars2 <- crse_vars %>%
  mutate(CourseID = paste(TERM_CD, tolower(deptOrgID), tolower(SBJCT_CD), tolower(CATALOG_NBR), tolower(CLASS_SECTION_CD), sep = '_')) %>%
  mutate(Instructor_External_ID = paste0(instrConstituentID, '@cu.edu'))

# fix (when needed)
crse_vars2 <- crse_vars2 %>%
  mutate(instrNm = case_when(
      instrNm == 'Santos, Ana' ~ 'Brown, Esther',
      TRUE ~ instrNm
    )) %>%
  mutate(instrLastNm = case_when(
      instrLastNm == 'Santos' ~ 'Brown',
      TRUE ~ instrLastNm
    )) %>%
  mutate(instrFirstNm = case_when(
      instrFirstNm == 'Ana' ~ 'Esther',
      TRUE ~ instrFirstNm
    )) %>%
  mutate(instrPersonID = case_when(
      instrPersonID == '999999999' ~ '   ',
      TRUE ~ instrPersonID
    )) %>%
  mutate(instrConstituentID = case_when(
      instrConstituentID == 'E30A5E7D-XXXX-4C2C-AC8C-5393CF4736C6' ~ '11B22CCB-XXXX-11e2-9D84-00505691002B',
      TRUE ~ instrConstituentID
    )) %>%
  mutate(instrEmplid = case_when(
      instrEmplid == 666666 ~ as.integer(666666),
      TRUE ~ instrEmplid
    )) %>%
  mutate(instrEmailAddr = case_when(
      instrEmailAddr == 'xxx@colorado.edu' ~ 'xxx@colorado.edu',
      TRUE ~ instrEmailAddr
    )) %>%
    mutate(Instructor_External_ID = case_when(
      Instructor_External_ID == 'E30A5E7D-XXXX-4C2C-AC8C-5393CF4736C6@cu.edu' ~ '11B22CCB-XXXX-11e2-9D84-00505691002B@cu.edu',
      TRUE ~ Instructor_External_ID
    ))

#########################################################################
# prepare FCQ result data
#########################################################################
# import response export file
bdraw <- read.csv('BD_response_export.csv')

# filter out late drops
bdraw2 <- bdraw %>%
  filter(Student.Identifier != 'No Identifier Found')

# fix bad crse IDs (if needed)
# bdraw <- bdraw %>%
#    mutate(Course.Section.External.Id = case_when(
#      Course.Section.External.Id == '2234_cubld:bldr:ev_envd_3009_841_sem' ~ '2234_cubld:bldr:ev_envd_3009_843_sem',
#     Course.Section.External.Id == '2234_cubld:bldr:ev_envd_3009_842_sem' ~ '2234_cubld:bldr:ev_envd_3009_844_sem',
#     TRUE ~ Course.Section.External.Id
#   ))

# create xlsx back up
write.xlsx(bdraw, 'BD_response_export_bak.xlsx', showNA = FALSE)

# create data file for Tableau/Excel reports
bddata <- bdraw[,c(1:2, 4:7, 10:11, 13:28)]

# create data file for text analysis
bdtxt <- bdraw[,c(1:2, 4:7, 10:11, 29)]

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

# at this point, bd_filled is ready

#########################################################################
# QC: output rows should match bd_comb_missing
bd_filled2 <- bd_filled %>%
  mutate(paired = paste0(Student_Identifier, '_', Course_Section_External_ID)) %>%
  distinct(paired)
#########################################################################

# fill bd_comb0 file
bd_comb1 <- left_join(bd_comb0, bd_inst_table, by = c('Course_Section_External_ID', 'Instructor_External_ID', 'Instructor'))
bd_comb2 <- bd_comb1 %>%
  relocate(c(Instructor, Instructor_External_ID), .before = Q01)

# keep only rows with all info

#########################################################################
# fix bad crseIDs in bd_comb_instrNm1 w bd_comb0(.x) and bd_inst_table(.y)
bd_comb0 <- bd_comb0 %>%
  mutate(Course_Section_External_ID = case_when(
    Course_Section_External_ID == '2237_cubld:bldr:ebio_ebio_5760_10_lec' ~ '2237_cubld:bldr:ebio_ebio_5760_010_lec',
    Course_Section_External_ID == '2237_cubld:bldr:eb_educ_6220_001_NA' ~ '2237_cubld:bldr:eb_educ_6220_001_sem',
    Course_Section_External_ID == '2237_cubld:bldr:geol_geol_5862_901_NA' ~ '2237_cubld:bldr:geol_geol_5862_901_ind',
    Course_Section_External_ID == '2237_cubld:bldr:eb_educ_5844_002_NA' ~ '2237_cubld:bldr:eb_educ_5844_002_lec',
    TRUE ~ Course_Section_External_ID
  )) %>%
  mutate(Course_Section_Label = case_when(
    Course_Section_Label == 'EBIO 5760(10): Mammalogy' ~ 'EBIO 5760(010): Mammalogy',
    TRUE ~ Course_Section_Label
  ))

bd_inst_table <- bd_inst_table %>%
  mutate(Course_Section_External_ID = case_when(
    CLASS_NUM == 26127 ~ '2241_cubld:bldr:cmdp_cmdp_4730_001_sem',
    CLASS_NUM == 24649 ~ '2241_cubld:bldr:cwcv_cwcv_4000_001_sem',
    CLASS_NUM == 22969 ~ '2241_cubld:bldr:mb_musc_3033_001_mls',
    CLASS_NUM == 26927 ~ '2241_cubld:bldr:eb_educ_5390_001_lec',
    CLASS_NUM == 23039 ~ '2241_cubld:bldr:mb_musc_6801_001_sem',
    CLASS_NUM == 35802 ~ '2241_cubld:bldr:phil_phil_5020_001_sem',
    CLASS_NUM == 23358 ~ '2241_cubld:bldr:mb_musc_5808_001_sem',
    CLASS_NUM == 39464 ~ '2241_cubld:bldr:geog_geog_4002_002_lec',
    CLASS_NUM == 27941 ~ '2241_cubld:bldr:iafs_iafs_4500_004_sem',
    CLASS_NUM == 33011 ~ '2241_cubld:bldr:ling_ling_5800_001_sem',
    CLASS_NUM == 32781 ~ '2241_cubld:bldr:info_info_4001_001_lec',
    CLASS_NUM == 22392 ~ '2241_cubld:bldr:aaah_arth_4939_001_int',
    CLASS_NUM == 37046 ~ '2241_cubld:bldr:csci_csci_7422_001_pra',
    CLASS_NUM == 26952 ~ '2241_cubld:bldr:eb_educ_5050_001_lec',
    TRUE ~ Course_Section_External_ID
  )) %>%
    mutate(Course_Section_External_ID = case_when(
    Course_Section_External_ID == '2237_cubld:bldr:ebio_ebio_5760_10_lec' ~ '2237_cubld:bldr:ebio_ebio_5760_010_lec',
    Course_Section_External_ID == '2237_cubld:bldr:eb_educ_6220_001_NA' ~ '2237_cubld:bldr:eb_educ_6220_001_sem',
    Course_Section_External_ID == '2237_cubld:bldr:geol_geol_5862_901_NA' ~ '2237_cubld:bldr:geol_geol_5862_901_ind',
    Course_Section_External_ID == '2237_cubld:bldr:eb_educ_5844_002_NA' ~ '2237_cubld:bldr:eb_educ_5844_002_lec',
    TRUE ~ Course_Section_External_ID
  ))

# then rerun from bd_filled until all is fixed
#########################################################################

# account for instr changes after administration
bd_comb_fixed <- bd_comb_instrNm0 %>%
  select(-c(instrNm, instrPersonID, CLASS_NUM)) %>%
  left_join(bd_inst_table, by = c('Course_Section_External_ID', 'Instructor_External_ID'))

bd_comb_fixed2 <- bd_comb_fixed %>%
  filter(!is.na(instrNm)) %>%
  select(-c(assoc_class_secID.x, spons_id.x)) %>%
  relocate(c(instrNm, instrPersonID, CLASS_NUM), .before = Q01)

bd_comb_fixed2b <- bd_comb_fixed %>%
  filter(is.na(instrNm)) %>%
  select(-c(assoc_class_secID.x, spons_id.x))

bd_comb_changed <- bd_comb_fixed %>%
  filter(is.na(instrNm)) %>%
  select(Course_Section_External_ID,Instructor,Instructor_External_ID) %>%
  distinct()

# isolate courses with changed instrs in bd_inst_table
bd_comb_swap <- bd_comb_changed %>%
  left_join(select(bd_inst_table, -c(instrNm, instrPersonID, Instructor_External_ID)), by = 'Course_Section_External_ID') %>%
  select(Instructor, assoc_class_secID, spons_id, CLASS_NUM, Course_Section_External_ID, Instructor_External_ID)

bd_comb_swap2 <- bd_comb_swap %>%
  left_join(select(bd_inst_table, c(instrNm, instrPersonID, Instructor_External_ID)), by = 'Instructor_External_ID')

bd_comb_swap3 <- bd_comb_swap2 %>%
  filter(!is.na(instrPersonID)) %>%
  select(-Instructor) %>%
  select(instrNm, instrPersonID, CLASS_NUM, Course_Section_External_ID, Instructor_External_ID) %>%
  distinct()

#########################################################################
# how to handle any missing instrs that remain
# need to look up these instrs in edb, then add to bd_inst_table
bd_comb_manual <- bd_comb_swap2 %>%
  filter(is.na(instrPersonID)) %>%
  select(-c(instrNm, instrPersonID))

edb2 <- edb %>%
  mutate(Instructor_External_ID = paste0(EMPLOYEE_CONSTITUENT_ID,'@cu.edu')) %>%
  rename(instrNm = Name, instrPersonID = SID) %>%
  select(instrNm, instrPersonID, Instructor_External_ID)

bd_comb_manual2 <- bd_comb_manual %>%
  left_join(edb2, by = 'Instructor_External_ID') %>%
  select(-Instructor) %>%
  relocate(c(instrNm, instrPersonID), .before = assoc_class_secID)

bd_comb_manual3 <- bd_comb_manual2 %>%
  left_join(pers, by = 'instrPersonID') %>%
  select(-c(instrNm, instrLastNm, instrFirstNm, instrMiddleNm)) %>%
  mutate(instrNm = str_replace(instrNm_src, ',', ', ')) %>%
  select(instrNm, instrPersonID, CLASS_NUM, Course_Section_External_ID, Instructor_External_ID)

bd_comb_fixed3 <- bd_comb_fixed2b %>%
  select(-c(instrNm, instrPersonID, CLASS_NUM)) %>%
  left_join(bd_comb_manual3, by = c('Course_Section_External_ID', 'Instructor_External_ID'))

bd_comb_fixed4 <- bd_comb_fixed3 %>%
  filter(!is.na(instrNm)) %>%
  relocate(c(instrNm, instrPersonID, CLASS_NUM), .before = Q01)

# find any remaining NAs
bd_comb_fixed3b <- bd_comb_fixed3 %>%
  filter(is.na(instrNm))

bd_comb_fixed5 <- bd_comb_fixed3b %>%
  select(-c(instrNm, instrPersonID, CLASS_NUM)) %>%
  left_join(bd_comb_swap3, by = c('Course_Section_External_ID', 'Instructor_External_ID'))

# combine all rows that have been fixed here
bd_comb_fixed6 <- rbind(bd_comb_fixed2, bd_comb_fixed4, bd_comb_fixed5)

#########################################################################
# now, put them together in corrected instr table
bd_final <- rbind(bd_comb2, bd_filled)
bd_final <- bd_final %>%
  mutate(CourseID = str_sub(Course_Section_External_ID, 1, str_length(Course_Section_External_ID)-4))
# bd_final <- rbind(bd_comb3, bd_filled, bd_comb_fixed6)

qc <- filter(bd_final, is.na(Instructor))

# if qc == 0, skip ahead to bd_final2 call

#######################
# fix if qc >= 1 and then rerun bd_final + qc
bd_filled <- bd_filled %>%
  mutate(Instructor = case_when(
    Course_Section_External_ID == '2247_cubld:bld3:ecea_ecea_5707_200_lec' ~ 'Maksimovic, Dragan',
    Course_Section_External_ID == '2247_cubld:bldr:chem_chem_6901_902_oth' ~ 'Damrauer, Niels',
    Course_Section_External_ID == '2247_cubld:bldr:math_math_5510_001_lec' ~ 'Nguyen, Nhan',
    Course_Section_External_ID == '2247_cubld:bldr:milr_milr_2031_020_lec' ~ 'Hoffman, Daniel',
    TRUE ~ Instructor
  )) %>%
  mutate(Instructor_External_ID = case_when(
    Course_Section_External_ID == '2247_cubld:bld3:ecea_ecea_5707_200_lec' ~ '0AE70B5F-XXXX-11e3-8F6C-005056941ADA@cu.edu',
    Course_Section_External_ID == '2247_cubld:bldr:chem_chem_6901_902_oth' ~ '3F481EA5-XXXX-11e3-A954-005056941ADA@cu.edu',
    Course_Section_External_ID == '2247_cubld:bldr:math_math_5510_001_lec' ~ '0B33A2F7-XXXX-400F-B426-F96726B3DD97@cu.edu',
    Course_Section_External_ID == '2247_cubld:bldr:milr_milr_2031_020_lec' ~ '0E67AE90-XXXX-11e2-861A-00505691002B@cu.edu',
    TRUE ~ Instructor_External_ID
  ))

# then rerun bd_final

##########################################################################
# Step 2: 
# create other vars
##########################################################################

bd_complete <- left_join(bd_final, crse_vars2, by = c( 'CourseID', 'Instructor_External_ID'), suffix = c('','.y')) %>%
  select(-ends_with('.y'))

# create other vars
bd_complete2 <- bd_complete %>%
  mutate(Semester = case_when(
    grepl('1$', term) ~ 'Spring',
    grepl('4$', term) ~ 'Summer',
    grepl('7$', term) ~ 'Fall')) %>%
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
  
##################################################################
# create summaries
##################################################################

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
  mutate(Term_cd = term)

# export bd_sum to csv
write.csv(bd_sum, 'BD_Instr_Summary_update.csv', row.names = FALSE)
