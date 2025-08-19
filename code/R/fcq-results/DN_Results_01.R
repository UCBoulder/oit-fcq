#########################################################################
# Process Denver FCQs
# created: Vince Darcangelo 5/24/22
# most recent update: Vince Darcangelo 8/29/24
# \AIM Measurement - Documents\FCQ\R_Code\dn_results\DN_Results_01.R
#########################################################################

library('lubridate')
library('openxlsx')
library('haven')
library('stringr')

# UPDATE THESE VARS EACH SEMESTER:
Year <- 2025
term_scores <- 2254
userid <- 'darcange'
filenm <- 'DN_response_export.csv'
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
    print('folder already exists.')
		setwd(folder_ex)
} else {
		dir.create(folder_ex)
    print('folder created.')
		setwd(folder_ex)
}

#########################################################################

drv <- dbDriver('Oracle')
connection_string <- '(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)
  (HOST=ciw.prod.cu.edu)(PORT=1525))(CONNECT_DATA=(SERVICE_NAME=CIW)))'
con <- dbConnect(drv, username = getOption('databaseuid'), 
  password = getOption('databasepword'), dbname = connection_string)

crse_vars <- read.csv(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CourseAudit_bak\\', term_scores, '\\c20.csv'))

# create CourseID in crsevars for matching
crse_vars2 <- crse_vars %>%
  mutate(CourseID = paste(TERM_CD, tolower(deptOrgID), tolower(SBJCT_CD), tolower(CATALOG_NBR), tolower(CLASS_SECTION_CD), sep = '_')) %>%
  mutate(Instructor_External_ID = paste0(instrConstituentID, '@cu.edu'))

#########################################################################
# prepare FCQ result data
#########################################################################
# import response export
dnraw <- read.csv('DN_response_export.csv')
write.xlsx(dnraw, 'DN_response_export_bak.xlsx', showNA = FALSE)

# filter out late drops
dnraw2 <- dnraw %>%
  filter(Student.Identifier != 'No Identifier Found')

dndata <- dnraw2[,c(1:2, 4:7, 10:11, 13:34)]

dntxt <- dnraw2[,c(1:2, 4:7, 10:11, 35:36)]

# rename columns
colnames(dndata) <- c('CE_Internal_ID', 'Student_Identifier', 'Course_Section_External_ID', 'Course_Section_Label', 'Department', 'Administration_Name', 'Instructor', 'Instructor_External_ID', 'Q01', 'Q02', 'Q03', 'Q04', 'Q05', 'Q06', 'Q07', 'Q08', 'Q09', 'Q10', 'Q11', 'Q12', 'Q13', 'Q14', 'Q15', 'Q16', 'Q17', 'Q18', 'Q19', 'Q20', 'Q21', 'Q22')

colnames(dntxt) <- c('CE_Internal_ID', 'Student_Identifier', 'Course_Section_External_ID', 'Course_Section_Label', 'Department', 'Administration_Name', 'Instructor', 'Instructor_External_ID', 'Comments1', 'Comments2')

# create key and separate course/instr items
dndata_crse <- dndata %>%
  filter(Instructor_External_ID == 'Course Section Results') %>%
  mutate(Key = paste0(CE_Internal_ID, Course_Section_External_ID, sep = '_')) %>%
  select(-c(Instructor, Instructor_External_ID, Q01, Q02, Q03, Q04, Q05, Q06, Q07, Q08, Q20))

dndata_inst <- dndata %>%
  filter(Instructor_External_ID != 'Course Section Results') %>%
  mutate(Key = paste0(CE_Internal_ID, Course_Section_External_ID, sep = '_')) %>%
  select(Key, Course_Section_Label, Instructor, Instructor_External_ID, Q01, Q02, Q03, Q04, Q05, Q06, Q07, Q08, Q20)

dntxt2 <- dntxt %>%
  filter(Instructor_External_ID != 'Course Section Results' & Comments1 != '' & Comments2 != '') %>%
  mutate(Key = paste(CE_Internal_ID, Course_Section_External_ID, sep = '_'))

##########################################################################
# combine course and instructor response rows, reorder with select()
dn_comb <- merge(x = dndata_crse, y = dndata_inst, by = c('Key', 'Course_Section_Label'), all.x = TRUE)
dn_comb <- dn_comb %>%
  relocate(c(Instructor, Instructor_External_ID, Q01, Q02, Q03, Q04, Q05, Q06, Q07, Q08), .before = Q09) %>%
  relocate(Q20, .before = Q21) %>%
  mutate(CourseID = substr(Course_Section_External_ID, 1, nchar(Course_Section_External_ID)-4))

# join dn_comb with class_num non-NCLL
dn_comb2a <- dn_comb %>%
  filter(Department != 'CU Denver College of Liberal Arts & Sci (NOCR:D-CLAS)') %>%
  mutate(SBJCT_CD = substr(Course_Section_Label, 1, 4)) %>%
  mutate(CATALOG_NBR = as.integer(substr(Course_Section_Label, 6, 9))) %>%
#  mutate(CLASS_SECTION_CD = substr(Course_Section_Label, 11, 14)) %>%
  mutate(CLASS_SECTION_CD = toupper(str_sub(Course_Section_External_ID, -8, -4))) %>%
  mutate(CLASS_SECTION_CD = gsub('_', '', CLASS_SECTION_CD))

# joing dn_comb with class_num NCLL
dn_comb2b <- dn_comb %>%
  filter(Department == 'CU Denver College of Liberal Arts & Sci (NOCR:D-CLAS)') %>%
  mutate(SBJCT_CD = substr(Course_Section_Label, 1, 4)) %>%
  mutate(CATALOG_NBR = as.integer(substr(Course_Section_Label, 6, 7))) %>%
  mutate(CLASS_SECTION_CD = substr(Course_Section_Label, 9, 11)) %>%
  mutate(CLASS_SECTION_CD = gsub(')', '', CLASS_SECTION_CD))

# rejoin classes
dn_comb2 <- rbind(dn_comb2a, dn_comb2b)

# separate blank instructor rows (stu completed 1+ crse q, but no instr q)
dn_comb2_missing <- dn_comb2 %>%
  filter(is.na(Instructor)) %>%
  select(-c(Instructor, Instructor_External_ID))

# pull class_num
dn_comb3 <- dn_comb2 %>%
  left_join(crse_vars2, by = c('SBJCT_CD', 'CATALOG_NBR', 'CLASS_SECTION_CD', 'Instructor_External_ID', 'CourseID')) %>%
  distinct()

#########################################################################
# QC: look for missing instr IDs
dn_comb4 <- dn_comb3 %>%
  filter(is.na(CLASS_NUM))

# how to handle missing instr IDs
if(nrow(dn_comb4) == 0){
  dn_comb4_final <- dn_comb3
  print('no missing IDs')
} else {
  dn_crse_errors <- dn_comb4 %>%
    select(CourseID, SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, Course_Section_External_ID)

  dn_crse_errors_distinct <- dn_crse_errors %>%
    distinct()

  dn_comb2_check <- dn_crse_errors_distinct %>%
    left_join(dn_comb2, c('SBJCT_CD', 'CATALOG_NBR', 'CLASS_SECTION_CD'))

  dn_crse_vars2_check <- dn_crse_errors_distinct %>%
    left_join(crse_vars2, c('SBJCT_CD', 'CATALOG_NBR', 'CLASS_SECTION_CD'))
}

##########################################################################
# QC1: IF DN_COMB4 > 0 and issue is in dn_comb2 (student didn't answer inst qs), then rerun from dn_comb2
dn_comb2 <- dn_comb2 %>%
  mutate(Instructor_External_ID = case_when(
    Course_Section_External_ID == '2247_cuden:clas:d-math_math_2421_001_lec' ~ 'XXXXX-7077-11e2-B656-00505691002B@cu.edu',
    Course_Section_External_ID == '2247_cuden:clas:d-math_math_2421_003_lec' ~ 'XXXXX-7077-11e2-B656-00505691002B@cu.edu',
    Course_Section_External_ID == '2247_cuden:clas:d-math_math_3195_001_lec' ~ 'XXXXX-7077-11e2-B656-00505691002B@cu.edu',
    Course_Section_External_ID == '2247_cuden:crss:d-ugxp_univ_1110_018_sem' ~ 'XXXXX1-7EBF-11e7-B994-005056945406@cu.edu',
    Course_Section_External_ID == '2247_cuden:paff:d-paff_crju_3530_e01_lec' ~ 'XXXXX-7328-11e2-895A-00505691002B@cu.edu',
    TRUE ~ Instructor_External_ID
  )) %>%
  mutate(Instructor = case_when(
    Course_Section_External_ID == '2247_cuden:clas:d-math_math_2421_001_lec' ~ 'Michael Kawai',
    Course_Section_External_ID == '2247_cuden:clas:d-math_math_2421_003_lec' ~ 'Michael Kawai',
    Course_Section_External_ID == '2247_cuden:clas:d-math_math_3195_001_lec' ~ 'Michael Kawai',
    Course_Section_External_ID == '2247_cuden:crss:d-ugxp_univ_1110_018_sem' ~ 'Christy Ridd',
    TRUE ~ Instructor
  ))

##########################################################################
# QC2: IF DN_COMB4 > 0 and issue is section code, use dn_crse_errors and dn_crse_vars2_check to fix, then rerun from where dn_comb2 joins with crse_vars2 to create, dn_comb3, then qc check for dn_comb3
# hint: usually, the correct code is SSR_COMP_CD, not crseSec_comp_cd

print(unique(dn_crse_vars5_check$Course_Section_External_ID))

crse_vars2 <- crse_vars2 %>%
  mutate(Course_Section_External_ID = case_when(
    Course_Section_External_ID == '2244_cuden:paff:d-paff_puad_4600_e01_sem' ~ '2244_cuden:paff:d-paff_puad_4600_e01_lec',
    Course_Section_External_ID == '2244_cuden:paff:d-paff_puad_4010_e01_sem' ~ '2244_cuden:paff:d-paff_puad_4010_e01_lec',
    Course_Section_External_ID == '2244_cuden:artm:d-vsla_fine_3135_950_sem' ~ '2244_cuden:artm:d-vsla_fine_3135_950_stu',
    Course_Section_External_ID == '2244_cuden:artm:d-meis_msra_5510_950_fld' ~ '2244_cuden:artm:d-meis_msra_5510_950_lec',
    Course_Section_External_ID == '2244_cuden:paff:d-paff_crju_6600_e01_lec' ~ '2244_cuden:paff:d-paff_crju_6600_e01_sem',
    TRUE ~ Course_Section_External_ID
  ))

crse_vars2 <- crse_vars2 %>%
  mutate(Instructor_External_ID = case_when(
    CourseID == '2247_cuden:clas:d-math_math_2421_001' ~ 'XXXX-XXXX-11e2-B656-00505691002B@cu.edu',
    CourseID == '2247_cuden:clas:d-math_math_2421_003' ~ 'XXXX-XXXX-11e2-B656-00505691002B@cu.edu',
    CourseID == '2247_cuden:clas:d-math_math_3195_001' ~ 'XXXX-XXXX-11e2-B656-00505691002B@cu.edu',
    CourseID == '2247_cuden:crss:d-ugxp_univ_1110_018' ~ 'XXXX-XXXX-11e7-B994-005056945406@cu.edu',
    CourseID == '2247_cuden:paff:d-paff_crju_3530_e01' ~ 'XXXX-XXXX-11e2-895A-00505691002B@cu.edu',
    TRUE ~ Instructor_External_ID
  ))

##########################################################################
# QC3: IF DN_COMB4 > 0, separate correct, find and fix errors
# set aside correct CLASS_SECTION_CD
dn_comb4x <- dn_comb3 %>%
  filter(!is.na(CLASS_NUM))

# find problematic sections - should be < 3 digits + have :
unique(dn_comb4$CLASS_SECTION_CD)

# fix problematic sections
dn_comb4_fixed <- dn_comb4 %>%
  mutate(CLASS_SECTION_CD = case_when(
    CLASS_SECTION_CD == '1: ' ~ '001',
    CLASS_SECTION_CD == '2: ' ~ '002',
    CLASS_SECTION_CD == '3: ' ~ '003',
    CLASS_SECTION_CD == '4: ' ~ '004',
    CLASS_SECTION_CD == '5: ' ~ '005',
    CLASS_SECTION_CD == '6: ' ~ '006',
    CLASS_SECTION_CD == '7: ' ~ '007',
    CLASS_SECTION_CD == '8: ' ~ '008',
    CLASS_SECTION_CD == '9: ' ~ '009',
    CLASS_SECTION_CD == '10:' ~ '010',
    CLASS_SECTION_CD == '11:' ~ '011',
    CLASS_SECTION_CD == '12:' ~ '012',
    CLASS_SECTION_CD == '13:' ~ '013',
    CLASS_SECTION_CD == '14:' ~ '014',
    CLASS_SECTION_CD == '15:' ~ '015',
    CLASS_SECTION_CD == '16:' ~ '016',
    CLASS_SECTION_CD == '17:' ~ '017',
    CLASS_SECTION_CD == '18:' ~ '018',
    CLASS_SECTION_CD == '19:' ~ '019',
    CLASS_SECTION_CD == '20:' ~ '020',
    CLASS_SECTION_CD == '21:' ~ '021',
    CLASS_SECTION_CD == '22:' ~ '022',
    CLASS_SECTION_CD == '23:' ~ '023',
    CLASS_SECTION_CD == '24:' ~ '024',
    CLASS_SECTION_CD == '25:' ~ '025'
  )) %>%
  select(-CLASS_NUM)

# rejoin with crse_aud2 to pick up Class_num
dn_comb4_fixed2 <- dn_comb4_fixed %>%
  left_join(crse_vars3, by = c('SBJCT_CD', 'CATALOG_NBR', 'CLASS_SECTION_CD', 'Instructor_External_ID')) %>%
  distinct()

# QC for missing Class_num (run for each - will return 0 if fixed)
dn_comb4_fixed3 <- dn_comb4_fixed2a %>%
#  filter(is.na(CLASS_SECTION_CD))
  filter(is.na(CLASS_NUM))

dn_comb4_fixed2a <- dn_comb4_fixed2 %>%
  filter(is.na(CLASS_NUM)) %>%
  mutate(CLASS_NUM = case_when(
    SBJCT_CD == 'MGMT' & CATALOG_NBR == '6825' ~ 10963,
    SBJCT_CD == 'INTB' & CATALOG_NBR == '4400' ~ 10821,
    SBJCT_CD == 'INTB' & CATALOG_NBR == '6500' ~ 10818
  )) %>%
  mutate(CLASS_SECTION_CD = case_when(
    CLASS_NUM == 10963 ~ 'E01',
    TRUE ~ CLASS_SECTION_CD
  ))

dn_comb4_fixed2b <- dn_comb4_fixed2 %>%
  !(filter(CLASS_NUM %in% c(10963, 10821, 10818))

# recombine fixed2a and 2b
dn_comb4_fixed2c <- rbind(dn_comb4_fixed2a, dn_comb4_fixed2b)

# recombine all
dn_comb4_final <- rbind(dn_comb4x, dn_comb4_fixed2c)
#########################################################################

# join dn_comb and crse_vars2
dn_comb5 <- dn_comb4_final %>%
  left_join(crse_vars2, by = c('CLASS_NUM', 'Instructor_External_ID', 'ACAD_GRP_CD', 'ACAD_GRP_LD', 'fcqdept', 'SBJCT_CD', 'CATALOG_NBR', 'CLASS_SECTION_CD', 'CRSE_LD', 'crseSec_comp_cd', 'instrNm', 'instrEmplid', 'totEnrl_nowd'))

#############################################################
# identify mismatches generated during join
dn_comb_err <- dn_comb5 %>% filter(is.na(SBJCT_CD)) %>% distinct()

# check the courses for errors - likely causes: changed instr constituent ID, incorrect dept/coll assign, class added manually after audit closed
dn_comb_ck2 <- dn_comb2 %>%
  filter(CourseID %in% c('2231_cuden:busn:d-busn_mgmt_4825_e01', '2231_cuden:busn:d-busn_mgmt_6825_e01', '2231_cuden:clas:d-rlst_rlst_4850_e01'))

dn_comb_ck2 <- dn_comb2 %>%
  filter(is.na(SBJCT_CD))

# make changes in dn_comb and then rerun to dn_comb2 call above
dn_comb <- dn_comb %>%
  mutate(Instructor_External_ID = case_when(
    Instructor == 'Robert Hobbins' & Course_Section_External_ID %in% c('2231_cuden:busn:d-busn_mgmt_4825_e01_lec', '2231_cuden:busn:d-busn_mgmt_6825_e01_lec') ~ 'XXXX-0798-4FE3-B73D-24D07C21060E@cu.edu',
    TRUE ~ Instructor_External_ID)) %>%
  mutate(Course_Section_External_ID = case_when(
    Course_Section_External_ID == '2231_cuden:clas:d-rlst_rlst_4850_e01_lec' ~ '2231_cuden:educ:d-rlst_rlst_4850_e01_lec',
    TRUE ~ Course_Section_External_ID)) %>%
  mutate(CourseID = case_when(
    Course_Section_External_ID == '2231_cuden:educ:d-rlst_rlst_4850_e01_lec' ~ '2231_cuden:educ:d-rlst_rlst_4850_e01',
    TRUE ~ CourseID))

#############################################################

dn_comb6 <- dn_comb5 %>%
  select('Course_Section_External_ID', 'Course_Section_Label', 'ACAD_GRP_CD', 'ACAD_GRP_LD', 'fcqdept', 'Department', 'SBJCT_CD', 'CATALOG_NBR', 'CLASS_SECTION_CD', 'CRSE_LD', 'crseSec_comp_cd', 'CLASS_NUM', 'instrNm', 'instrEmplid', 'totEnrl_nowd', 'Q01', 'Q02', 'Q03', 'Q04', 'Q05', 'Q06', 'Q07', 'Q08', 'Q09', 'Q10', 'Q11', 'Q12', 'Q13', 'Q14', 'Q15', 'Q16', 'Q17', 'Q18', 'Q19', 'Q20', 'Q21', 'Q22')

##################################################################
# one-time fix for 2247 (dept changed instrs AFTER administration)
fix2 <- dn_crse_errors_distinct %>%
  left_join(dn_comb5, 'Course_Section_External_ID') %>%
  select(Course_Section_External_ID, CLASS_NUM, instrNm) %>%
  distinct()

fix3 <- dn_comb5 %>%
  filter(!(CLASS_NUM %in% c(15617, 15720, 15841, 18171, 39530)))

fix4 <- dn_comb5 %>%
  filter(CLASS_NUM %in% c(15617, 15720, 15841, 18171, 39530)) %>%
  filter(!(instrEmplid %in% c(412514, 180802))) %>%
  mutate(instrConstituentID.x = case_when(
    CLASS_NUM == 39530 ~ 'XXXX-7328-11e2-895A-00505691002B',
    CLASS_NUM == 15617 ~ 'XXXX-7077-11e2-B656-00505691002B',
    CLASS_NUM == 15720 ~ 'XXXX-7077-11e2-B656-00505691002B',
    CLASS_NUM == 15841 ~ 'XXXX-7077-11e2-B656-00505691002B',
    CLASS_NUM == 18171 ~ 'XXXX-7EBF-11e7-B994-005056945406'
  ))

fix4 <- dn_comb5 %>%
  filter(CLASS_NUM != 15617 & !(instrEmplid %in% c(412514, 180802))) %>%
  filter(CLASS_NUM != 15720 & !(instrEmplid %in% c(412514, 180802)))

fix4b <- perstbl %>%
  filter(EMPLID %in% c(830090926, 109120840, 109248253))

fix4c <- hr %>%
  filter(PERSON_SID %in% c(1805655, 1708246, 803407))

dn_comb5 <- rbind(fix3, fix4)

dn_comb6 <- dn_comb5 %>%
  select('Course_Section_External_ID', 'Course_Section_Label', 'ACAD_GRP_CD', 'ACAD_GRP_LD', 'fcqdept', 'Department', 'SBJCT_CD', 'CATALOG_NBR', 'CLASS_SECTION_CD', 'CRSE_LD', 'crseSec_comp_cd', 'CLASS_NUM', 'Instructor', 'instrNm', 'instrEmplid', 'totEnrl_nowd', 'Q01', 'Q02', 'Q03', 'Q04', 'Q05', 'Q06', 'Q07', 'Q08', 'Q09', 'Q10', 'Q11', 'Q12', 'Q13', 'Q14', 'Q15', 'Q16', 'Q17', 'Q18', 'Q19', 'Q20', 'Q21', 'Q22')

dn_comb6a <- dn_comb6 %>%
  filter(!(CLASS_NUM %in% c(15617, 15720, 15841, 18171, 39530)))

dn_comb6b <- dn_comb6 %>%
  filter(CLASS_NUM %in% c(15617, 15720, 15841, 18171, 39530))

dn_comb6c <- dn_comb6b %>%
  mutate(instrEmplid = case_when(
    instrEmplid == 244563 ~ 137780,
    instrEmplid == 268114 ~ 137780,
    instrEmplid == 368362 ~ 137780,
    instrEmplid == 368165 ~ 311668,
    instrEmplid == 411377 ~ 411377
  )) %>%
  mutate(instrNm = case_when(
    Instructor == 'Christy Ridd' ~ 'Ridd, Christy',
    Instructor == 'Michael Kawai' ~ 'Kawai, Michael Hiroshi',
    TRUE ~ instrNm
  ))

dn_comb6d <- rbind(dn_comb6a, dn_comb6c)
dn_comb6 <- dn_comb6d %>%
  select(-Instructor)
##################################################################

dn_comb7 <- dn_comb6 %>%
  mutate(Semester = case_when(
    grepl('1$', term_scores) ~ 'Spring',
    grepl('4$', term_scores) ~ 'Summer',
    grepl('7$', term_scores) ~ 'Fall')) %>%
  mutate(Year = Year) %>%
  mutate(Course_Level = case_when(
    grepl('^NCLL', Course_Section_Label) ~ 'Lower',
    CATALOG_NBR >= 5000 ~ 'Graduate',
    CATALOG_NBR >= 3000 ~ 'Upper',
    CATALOG_NBR <= 2999 ~ 'Lower'))

# replace 0 with NA for calculations
dn_comb7[, 16:37][dn_comb7[, 16:37] == 0] <- NA

# create stuComp column
dn_comb7$stuComp <- format(round(rowMeans(dn_comb7[16:23], na.rm=TRUE),1))

##################################################################
# create match table for batch processing
dn_batch_match <- dn_comb5 %>%
  select(Instructor, Instructor_External_ID, fcqdept, ACAD_ORG_CD.x, SBJCT_CD) %>%
  distinct()

colnames(dn_batch_match) <- c('Instructor', 'Instructor_External_ID', 'fcqdept', 'ACAD_ORG_CD', 'SBJCT_CD')

# export instr table to csv
write.csv(dn_batch_match, 'DN_Inst_Batch.csv', row.names = FALSE)

##################################################################
# create summaries

# for tableau and tableau inst summary
dn_tab <- dn_comb7 %>%
  mutate(across(Q01:Q22, ~replace(.x, is.nan(.x), ''))) %>%
  mutate(Year = as.character(Year)) %>%
  select('Semester', 'Year', 'Course_Section_External_ID', 'Course_Section_Label', 'SBJCT_CD', 'CATALOG_NBR', 'CLASS_SECTION_CD', 'Course_Level', 'crseSec_comp_cd', 'instrNm', 'ACAD_GRP_CD', 'ACAD_GRP_LD', 'Department', 'totEnrl_nowd', 'stuComp', 'Q01', 'Q02', 'Q03', 'Q04', 'Q05', 'Q06', 'Q07', 'Q08', 'Q09', 'Q10', 'Q11', 'Q12', 'Q13', 'Q14', 'Q15', 'Q16', 'Q17', 'Q18', 'Q19', 'Q20', 'Q21', 'Q22', 'CLASS_NUM')

# export master update
write.csv(dn_tab, 'DN_Tableau_master_update.csv', row.names = FALSE)

# create dn_grpd for class summaries
dn_grpd <- dn_comb7 %>%
  group_by(across(c(Semester, Year, CLASS_NUM, Course_Section_Label, instrNm, instrEmplid, ACAD_GRP_LD, fcqdept, totEnrl_nowd))) %>%
  summarise(across(Q01:Q22, mean, na.rm = TRUE), responses = n()) %>%
  mutate(across(Q01:Q22, round, 1)) %>%
  relocate(responses, .before = Q01)

######################################################
# review col numbers to confirm 11:18 is still correct
# create Composite column
dn_grpd$Composite <- format(round(rowMeans(dn_grpd[11:18], na.rm=TRUE),1))

# create Response_Rate column
dn_grpd2 <- dn_grpd %>%
  mutate(rr = responses/totEnrl_nowd)

# format percentages
dn_grpd2$Response_Rate <- scales::percent(dn_grpd2$rr, digits = 1)

# arrange columns
dn_grpd3 <- dn_grpd2 %>%
  select(-rr) %>%
  relocate(c(Response_Rate, Composite), .before = Q01)

# for Dave (DN IR): use dn_grpd3 for semester updates
write.csv(dn_grpd3, 'DN_IR_data.csv', row.names = FALSE)

# for tableau resp rates tab
dn_rr <- dn_grpd3 %>%
  ungroup() %>%
  select(-c(CLASS_NUM, instrEmplid, ACAD_GRP_LD, fcqdept)) %>%
#  mutate(Year = as.character(Year)) %>%
  mutate(across(Q01:Q22, ~replace(.x, is.nan(.x), '')))

# UPDATE for Response_Rates tab in DN_FCQ_Report_Master.xlsx
# These are the vars!!!!!
#Term,Year,Class,Instructor,Enrollment,Responses,Response_Rate,Composite Score,Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9,Q10,Q11,Q12,Q13,Q14,Q15,Q16,Q17,Q18,Q19,Q20,Q21,Q22

write.csv(dn_rr, 'DN_Tableau_RR_update.csv', row.names = FALSE)

# for Excel instructor summary
dn_xls <- dn_grpd3 %>%
  ungroup() %>%
  select(-(instrEmplid))

# prep for Excel summary update file
dn_comb8 <- dn_comb7 %>%
  select(Semester, Year, CLASS_NUM, SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, CRSE_LD, Course_Level) %>%
  unique()

# combine with dn_comb8 to pull in crse data
dn_xls_update <- merge(x = dn_xls, y = dn_comb8, by = c('CLASS_NUM', 'Semester', 'Year'), all.x = TRUE)

dn_xls_update <- dn_xls_update %>%
  select(Semester,Year,ACAD_GRP_LD,fcqdept,SBJCT_CD,CATALOG_NBR,CLASS_SECTION_CD,CRSE_LD,instrNm,Course_Level,totEnrl_nowd,responses,Response_Rate,Composite,Q01,Q02,Q03,Q04,Q05,Q06,Q07,Q08,Q09,Q10,Q11,Q12,Q13,Q14,Q15,Q16,Q17,Q18,Q19,Q20,Q21,Q22) %>%
  mutate(Year = as.character(Year)) %>%
  mutate(CLASS_SECTION_CD = as.character(CLASS_SECTION_CD)) %>%
  mutate(across(Q01:Q22, ~replace(.x, is.nan(.x), ''))) %>%
  mutate(Term_cd = term_scores)

# are there missing fcqdept from new subj?
dn_xls_update0 <- dn_xls_update %>%
  filter(fcqdept == '----')

# fix missing fcqdept in dn_xls_update file
# dn_xls_update <- dn_xls_update %>%
#   mutate(fcqdept = case_when(
#     SBJCT_CD == 'IDMA' ~ 'CLAS',
#     SBJCT_CD == 'INTD' ~ 'AP',
#     TRUE ~ fcqdept))

# dn_comb4 <- dn_comb4 %>%
#   mutate(fcqdept = case_when(
#     fcqdept == 'PSYC' ~ 'PSY',
#     TRUE ~ fcqdept))

# print summary
write.csv(dn_xls_update, 'DN_inst_summ_update.csv', row.names = FALSE)

# create mean score file tab in Excel summary file
dn_means <- dn_comb7 %>%
  group_by(Semester, Year, ACAD_GRP_LD, fcqdept) %>%
  mutate(Year = as.character(Year)) %>%
  summarise(across(Q01:Q22, mean, na.rm = TRUE)) %>%
  mutate(across(Q01:Q22, round, 1))

write.csv(dn_means, 'DN_means_update.csv', row.names = FALSE)

##########################################################################
# DN business combined report
##########################################################################

folder_busn <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\Data_Requests\\DN\\Dept_Summaries\\')

report_term <- as.character(term_scores)

dn_solo <- dn_comb4_final %>%
  filter(is.na(SCTN_CMBND_CD))

dn_solo2 <- dn_solo %>%
  select('Course_Section_External_ID', 'Course_Section_Label', 'ACAD_GRP_CD', 'ACAD_GRP_LD', 'fcqdept', 'Department', 'SBJCT_CD', 'CATALOG_NBR', 'CLASS_SECTION_CD', 'CRSE_LD', 'crseSec_comp_cd', 'CLASS_NUM', 'instrNm', 'totEnrl_nowd_comb', 'Q01', 'Q02', 'Q03', 'Q04', 'Q05', 'Q06', 'Q07', 'Q08', 'Q09', 'Q10', 'Q11', 'Q12', 'Q13', 'Q14', 'Q15', 'Q16', 'Q17', 'Q18', 'Q19', 'Q20', 'Q21', 'Q22', 'combStat', 'spons_AcadGrp', 'spons_AcadOrg', 'spons_fcqdept', 'spons_deptOrgID', 'spons_id', 'SCTN_CMBND_CD', 'SCTN_CMBND_LD')

dn_solo3 <- dn_solo2 %>%
  mutate(Semester = sem) %>%
  mutate(Year = Year) %>%
  group_by(Semester, Year, spons_id, instrNm, spons_fcqdept) %>%
  summarise(across(Q01:Q22, mean, na.rm = TRUE)) %>%
  mutate(across(Q01:Q22, round, 1)) %>%
  filter(spons_fcqdept == 'BD')

dn_spon <- dn_comb4_final %>%
  filter(!is.na(SCTN_CMBND_CD))

dn_spon2 <- dn_spon %>%
  select('Course_Section_External_ID', 'Course_Section_Label', 'ACAD_GRP_CD', 'ACAD_GRP_LD', 'fcqdept', 'Department', 'SBJCT_CD', 'CATALOG_NBR', 'CLASS_SECTION_CD', 'CRSE_LD', 'crseSec_comp_cd', 'CLASS_NUM', 'instrNm', 'totEnrl_nowd_comb', 'Q01', 'Q02', 'Q03', 'Q04', 'Q05', 'Q06', 'Q07', 'Q08', 'Q09', 'Q10', 'Q11', 'Q12', 'Q13', 'Q14', 'Q15', 'Q16', 'Q17', 'Q18', 'Q19', 'Q20', 'Q21', 'Q22', 'combStat', 'spons_AcadGrp', 'spons_AcadOrg', 'spons_fcqdept', 'spons_deptOrgID', 'spons_id', 'SCTN_CMBND_CD', 'SCTN_CMBND_LD')

dn_spon3 <- dn_spon2 %>%
  mutate(Semester = sem) %>%
  mutate(Year = Year) %>%
  group_by(Semester, Year, spons_id, instrNm, spons_fcqdept) %>%
  summarise(across(Q01:Q22, mean, na.rm = TRUE)) %>%
  mutate(across(Q01:Q22, round, 1)) %>%
  filter(spons_fcqdept == 'BD')

dn_busn_comb <- rbind(dn_spon3, dn_solo3)

# create style for top row
Heading <- createStyle(textDecoration = 'bold', fgFill = '#FFFFCC', border = 'TopBottomLeftRight')

# workbook call begins here
dn_busn_rept <- createWorkbook()
addWorksheet(dn_busn_rept, report_term, gridLines = TRUE)
writeData(dn_busn_rept, report_term, dn_busn_comb, withFilter = TRUE)

# freeze top row
freezePane(dn_busn_rept, report_term, firstActiveRow = 2, firstActiveCol = 1)

# add style to header
addStyle(dn_busn_rept, report_term, cols = 1:ncol(dn_busn_comb), rows = 1, style = Heading)

# daily (no date, goes to shared drive)
saveWorkbook(dn_busn_rept, paste0(folder_busn, report_term, '_DN_BD_Combined.xlsx'), overwrite = TRUE)
