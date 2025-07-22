##########################################################################
# creating .csv files to import to Campus Labs for FCQ administration
# created: Vince Darcangelo, 10/24/22
# most recent update: Vince Darcangelo 3/21/25
# \AIM Measurement - FCQ\R_Code\campus_labs\CL_Imports.R
# csv files generated in \AIM Measurement - FCQ\CampusLabs\Imports\term_cd
##########################################################################

# reformat deptOrgID
clscu3$deptOrgID <- gsub("_",":",clscu3$deptOrgID)

# update batch number: updated to batch 11 on 7/18 -vd
sess_num <- '11'
batch <- paste0('batch', sess_num)

# filter for desired session
session <- clscu3 %>%
 filter(adminDtTxt == 'Jul 21-Jul 25')
# filter(adminInd == 1 & campus == 'MC' & SBJCT_CD == 'BMSC' & CATALOG_NBR == '7812')
# filter(adminInd == 1 & CLASS_NUM %in% c(35857, 36011))
# final session filters
# filter(campus == 'B3' & adminDtTxt == 'Apr 21-Apr 29')
# filter(campus == 'CE' & SESSION_CD == 'BSO' & adminDtTxt == 'Apr 21-Apr 29')
# filter(campus == 'CE' & SESSION_CD != 'BSO' & adminDtTxt == 'Apr 21-Apr 29')
# ENGR extended final
# filter(campus == 'BD' & SBJCT_CD %in% c('GEEN', 'ENED', 'MCEN') & adminDtTxt == 'Apr 21-May 01')
# LAWS early final
# filter(campus == 'BD' & SBJCT_CD == 'LAWS' & adminDtTxt == 'Apr 20-Apr 27')
# filter(campus == 'BD' & adminDtTxt == 'Apr 21-Apr 29')
# filter(campus == 'DN' & LOC_ID == 'IC_BEIJING' & adminDtTxt == 'Nov 18-Dec 03')
# filter(campus == 'DN' & adminDtTxt == 'Apr 28-May 06')
# filter(campus == 'MC' & adminDtTxt == 'Apr 28-May 06')
view(session)

# set term_cd
term_cd <- 2254
userid <- 'darcange'
folder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\')
import_path <- paste0(folder, 'CampusLabs//Imports//', term_cd)

#########################################################################
# pull from PS_D_PERSON as studeth for stu acct info
studeth_log <- paste0(folder, 'CampusLabs\\Data_Files\\studeth.rds')
current_date <- Sys.Date()
log_date <- readRDS(studeth_log)

if (current_date != log_date) {
  studeth <- dbGetQuery(con,
  "SELECT PERSON_SID, PERSON_ID, DEATH_DT
  FROM PS_D_PERSON")

  # update .rds file
  saveRDS(current_date, studeth_log)

} else {
  print('studeth exists.')
}

# pull from PS_F_CLASS_ENRLMT as stuenrl for stu acct info
stuenrl_log <- paste0(folder, 'CampusLabs\\Data_Files\\stuenrl.rds')
current_date <- Sys.Date()
log_date <- readRDS(stuenrl_log)

if (current_date != log_date) {
  stuenrl <- dbGetQuery(con,
  "SELECT CLASS_SID, PERSON_SID, ENRLMT_STAT_SID, ENRLMT_DROP_DT_SID, ACAD_PROG_SID, GRADE_DT, CRSE_GRADE_OFF
  FROM PS_F_CLASS_ENRLMT")
  
  # update .rds file
  saveRDS(current_date, stuenrl_log)

} else {
  print('stuenrl exists.')
}

#########################################################################
# inst account csv
instAcct_import <- session %>%
  ungroup() %>%
  select(instrConstituentID, instrFirstNm, instrLastNm, instrEmailAddr) %>%
  mutate(instrConstituentID = paste0(instrConstituentID, "@cu.edu")) %>%
  distinct()

colnames(instAcct_import) <- c("PersonIdentifier", "FirstName", "LastName", "Email")

###XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX###
### MISSING EMAIL SEQUENCE
### error check -- do all the instructors have PREF_EMAIL?
emCheck1 <- instAcct_import %>%
  filter(Email %in% c('','-'))

if (nrow(emCheck1) == 0) {

# create file for CL import
    write.csv(instAcct_import, paste0(import_path, '\\Accounts\\instrAcct', term_cd, '_', batch, '.csv'), row.names = FALSE)

# create running cumulative file
    instAcct_upd <- instAcct_import %>%
      mutate(batch = sess_num)

# import existing log
    instAcctLog <- read.csv(paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\instAcct_All.csv'))

# add new batch data to existing log
    instAcct_all <- rbind(instAcctLog, instAcct_upd)

# update cumulative file
    write.csv(instAcct_all, paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\instAcct_All.csv'), row.names = FALSE)

# save batch data to CL data_files
    save(instAcct_upd, file = paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\instAcct_', batch, '.Rdata'))

  } else {
    View(emCheck1)
    file.edit(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\R_Code\\campus_labs\\emCheck1.R'))
    stop('Review the missing emails, update and run code in emCheck1.R, then rerun from emCheck1')
  }

###XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX####

#########################################################################
# stu account csv
# prep pers/cid/em_stu files for students
pers_stu <- pers

colnames(pers_stu) <- c('PERSON_SID', 'stuPersonID', 'EFFDT', 'EFF_STATUS', 'stuNm_src', 'stuLastNm', 'stuFirstNm', 'stuMiddleNm', 'NAME_TYPE', 'CURRENT_IND', 'DisplayNm', 'name_pref')

cid_stu <- cid
colnames(cid_stu) <- c("stuPersonID", "stuConstituentID")

em_stu <- em
colnames(em_stu) <- c("stuPersonID", "PREF_EMAIL", "BLD_EMAIL", "CONT_ED_EMAIL", "DEN_EMAIL")

# pull CLASS_SID from cx2 to match later
cx2 <- cx %>%
  select(CLASS_NUM, CLASS_SID)

# filter from studeth by death_dt
studeth2 <- studeth %>%
  filter(DEATH_DT == '1900-01-01')

# join session with cx2 on CLASS_NUM
stuAcct <- session %>%
  left_join(cx2, "CLASS_NUM") %>%
  left_join(stuenrl, "CLASS_SID") %>%
  left_join(pers_stu, "PERSON_SID") %>%
  left_join(cid_stu, "stuPersonID") %>%
  left_join(em_stu, "stuPersonID") %>%
  mutate(stuConstituentID = paste0(stuConstituentID, "@cu.edu"))

# reduce columns to those required by Campus Labs
stuAcct_import <- stuAcct %>%
  ungroup() %>%
  select(stuConstituentID, stuFirstNm, stuLastNm, PREF_EMAIL) %>%
  distinct()
colnames(stuAcct_import) <- c("PersonIdentifier", "FirstName", "LastName", "Email")

###XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX###
### MISSING EMAIL SEQUENCE
### error check -- do all the students have PREF_EMAIL?
emCheck2 <- stuAcct_import %>%
  filter(Email %in% c('','-'))

if (nrow(emCheck2) == 0) {

# create file for CL import
    write.csv(stuAcct_import, paste0(import_path, '\\Accounts\\stuAcct', term_cd, '_', batch, '.csv'), row.names = FALSE)

# create running cumulative file
    stuAcct_upd <- stuAcct_import %>%
      mutate(batch = sess_num)

# import existing log
    stuAcctLog <- read.csv(paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\stuAcct_All.csv'))

# add new batch data to existing log
    stuAcct_all <- rbind(stuAcctLog, stuAcct_upd)

# update cumulative file
    write.csv(stuAcct_all, paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\stuAcct_All.csv'), row.names = FALSE)

# save batch data to CL data_files
    save(stuAcct_upd, file = paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\stuAcct_', batch, '.Rdata'))

  } else {
    View(emCheck2)
    file.edit(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\R_Code\\campus_labs\\emCheck2.R'))
    stop('Review the missing emails, update and run code in emCheck2.R, then rerun from emCheck2')
  }

###XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX####

#########################################################################
# course csv
crsecsv <- session %>%
  ungroup() %>%
  select(SBJCT_CD, CATALOG_NBR, CRSE_LD, deptOrgID) %>%
  mutate(CourseIdentifier = paste(deptOrgID, SBJCT_CD, CATALOG_NBR, sep = "_")) %>%
  mutate(Type = case_when(
    CATALOG_NBR <= 4999 ~ "Undergraduate",
    CATALOG_NBR >= 5000 & SBJCT_CD != "LAWS" ~ "Graduate",
    TRUE ~ "Professional"
  )) %>%
  add_column(Credits = '', Description = '', CIPCode = '') %>%
  relocate(CourseIdentifier, .before = SBJCT_CD) %>%
  relocate(Credits, .after = "CRSE_LD") %>%
  distinct()

colnames(crsecsv) <- c("CourseIdentifier", "Subject", "Number", "Title", "Credits", "OrgUnitIdentifier", "Type", "Description", "CIPCode")

# create file for CL import
write.csv(crsecsv, paste0(import_path, '\\Course\\Course', term_cd, '_', batch, '.csv'), row.names = FALSE)

# create running cumulative file
crse_upd <- crsecsv %>%
  mutate(batch = sess_num)

# import existing log
crseLog <- read.csv(paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\Crse_All.csv'))

# add new batch data to existing log
crse_all <- rbind(crseLog, crse_upd)

# update cumulative file
write.csv(crse_all, paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\Crse_All.csv'), row.names = FALSE)

# save batch data to CL data_files
save(crse_upd, file = paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\Crse_',batch,'.Rdata'))

#########################################################################
# section csv
# format dates and times
session$mtgStartDt <- strptime(session$mtgStartDt, "%m/%d/%Y")
session$mtgEndDt <- strptime(session$mtgEndDt, "%m/%d/%Y")
sub(" MDT", "", session$mtgStartDt)
sub(" MDT", "", session$mtgEndDt)
session$nSD <- substr(session$mtgStartDt, 1, 10)
session$nED <- substr(session$mtgEndDt, 1, 10)

# create mtgStartDt, mtgEndDt, SectionIdentifier
session2 <- session %>%
  select(-c(mtgStartDt, mtgEndDt)) %>%
  mutate(mtgStartDt = nSD) %>%
  mutate(mtgEndDt = nED) %>%
  mutate(SectionIdentifier = paste(term_cd, deptOrgID, SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, SSR_COMP_CD, sep = "_")) %>%
  select(-c(nSD, nED))

# xlist sequence: isolate sponsor sects
xlist <- session2 %>%
  filter(combStat == 'S') %>%
    mutate(CrossListingIdentifier = SectionIdentifier) %>%
  ungroup() %>%
  select(campus, spons_id, CrossListingIdentifier)

# join CrossListingIdentifier
session3 <- session2 %>%
  left_join(xlist, c("campus", "spons_id"))

sectcsv <- session3 %>%
  ungroup() %>%
  select(SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, CRSE_LD, deptOrgID, SSR_COMP_CD, INSTITUTION_CD, CAMPUS_CD, mtgStartDt, mtgEndDt, INSTRCTN_MODE_CD, LOC_ID, SectionIdentifier, CrossListingIdentifier) %>%
  mutate(CrossListingIdentifier = case_when(
    is.na(CrossListingIdentifier) ~ '',
    TRUE ~ CrossListingIdentifier)) %>%
  mutate(TermIdentifier = case_when(
    CAMPUS_CD %in% c("BLD3", "BLDR", "CEPS") ~ paste(term_cd, INSTITUTION_CD, CAMPUS_CD, sep = ":"),
    TRUE ~ paste(term_cd, INSTITUTION_CD, sep = ":"))) %>%
  mutate(CourseIdentifier = paste(deptOrgID, SBJCT_CD, CATALOG_NBR, sep = "_")) %>%
  mutate(BeginDate = paste0(strftime(mtgStartDt, "%Y-%m-%d"), "T18:00:00-06:00")) %>%
  mutate(EndDate = paste0(strftime(mtgEndDt, "%Y-%m-%d"), "T18:00:00-06:00")) %>%
  mutate(DeliveryMode = case_when(
    INSTRCTN_MODE_CD %in% c("OL", "OS", "SO") ~ "ONLINE",
    INSTRCTN_MODE_CD %in% c("HY", "HN", "H1", "H2") ~ "HYBRID",
    TRUE ~ "FACE2FACE")) %>%
  add_column(Credits = '', Description = '', CIPCode = '') %>%
  select(SectionIdentifier, TermIdentifier, CourseIdentifier, SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, BeginDate, EndDate, deptOrgID, CRSE_LD, Credits, DeliveryMode, LOC_ID, Description, CrossListingIdentifier) %>%
  distinct()

colnames(sectcsv) <- c("SectionIdentifier", "TermIdentifier", "CourseIdentifier", "Subject", "CourseNumber", "Number", "BeginDate", "EndDate", "OrgUnitIdentifier", "Title", "Credits", "DeliveryMode", "Location", "Description", "CrossListingIdentifier")

# create file for CL import
write.csv(sectcsv, paste0(import_path, '\\Section\\Section', term_cd, '_', batch, '.csv'), row.names = FALSE)

# create running cumulative file
sect_upd <- sectcsv %>%
  mutate(batch = sess_num)

# import existing log
sectLog <- read.csv(paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\Sect_All.csv'))

# add new batch data to existing log
sect_all <- rbind(sectLog, sect_upd)

# update cumulative file
write.csv(sect_all, paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\Sect_All.csv'), row.names = FALSE)

# save batch data to CL data_files
save(sect_upd, file = paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\Sect_',batch,'.Rdata'))

#########################################################################
# inst csv
instcsv <- session %>%
  ungroup() %>%
  select(instrConstituentID, deptOrgID, SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, SSR_COMP_CD, instrFirstNm, instrLastNm, instrEmailAddr, INSTRCTR_ROLE_CD) %>%
  mutate(PersonIdentifier = paste0(instrConstituentID, "@cu.edu")) %>%
  mutate(SectionIdentifier = paste(term_cd, deptOrgID, SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, SSR_COMP_CD, sep = "_")) %>%
  mutate(Role = case_when(
    INSTRCTR_ROLE_CD == "PI" ~ "Primary",
    INSTRCTR_ROLE_CD == "SI" ~ "Secondary",
    INSTRCTR_ROLE_CD == "TA" ~ "TeachingAssistant"
  )) %>%
  select(PersonIdentifier, SectionIdentifier, instrFirstNm, instrLastNm, instrEmailAddr, Role) %>%
  distinct() %>%
  mutate(instrFirstNm = case_when(
    instrFirstNm == '' ~ '.',
    TRUE ~ instrFirstNm)) %>%
  mutate(instrLastNm = case_when(
    instrLastNm == '' ~ '.',
    TRUE ~ instrLastNm))

colnames(instcsv) <- c("PersonIdentifier", "SectionIdentifier", "FirstName", "LastName", "Email", "Role")

###XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX###
### MISSING EMAIL SEQUENCE
### error check -- do all the instructors have PREF_EMAIL?
emCheck3 <- instcsv %>%
  filter(Email %in% c('','-'))

if (nrow(emCheck3) == 0) {
    print('All instructors have PREF_EMAIL')
  } else {
    View(emCheck3)
    stop('Review and fix the missing emails, then rerun')
  }

###XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX####

# create file for CL import
write.csv(instcsv, paste0(import_path, '\\Instructor\\instr', term_cd, '_', batch, '.csv'), row.names = FALSE)

# create running cumulative file
inst_upd <- instcsv %>%
  mutate(batch = sess_num)

# import existing log
instLog <- read.csv(paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\Inst_All.csv'))

# add new batch data to existing log
inst_all <- rbind(instLog, inst_upd)

# update cumulative file
write.csv(inst_all, paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\Inst_All.csv'), row.names = FALSE)

# save batch data to CL data_files
save(inst_upd, file = paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\Inst_',batch,'.Rdata'))

#########################################################################
# stu enrl

# filter by drop dt and withdrawls
studrp2 <- stuenrl %>%
#  filter(ENRLMT_DROP_DT_SID <= 19000101 & CRSE_GRADE_OFF != 'W')
  filter(ENRLMT_STAT_SID == 3)

# join studrp2 and studeth2
studrp3 <- studrp2 %>%
  left_join(studeth2, "PERSON_SID") %>%
  drop_na(ENRLMT_DROP_DT_SID, CRSE_GRADE_OFF, DEATH_DT)

# join studrp3 with stuAcct
drops <- stuAcct %>%
  left_join(studrp3, c("CLASS_SID", "PERSON_SID"))

# assign enrollment status
drops2 <- drops %>%
  mutate(Status = case_when(
    CRSE_GRADE_OFF.x == 'W' ~ 'Withdrawn',
    ENRLMT_STAT_SID.x == 3 ~ 'Enrolled',
    TRUE ~ 'Dropped'
  ))

# reduce to match columns
drops3 <- drops2 %>%
  select(CLASS_NUM, PERSON_SID, stuPersonID, instrPersonID, Status)

# create stuEnrl2 doc to match
stuEnrl2 <- stuAcct_import %>%
  left_join(stuAcct, c("PersonIdentifier" = "stuConstituentID")) %>%
  mutate(SectionIdentifier = paste(term_cd, deptOrgID, SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, SSR_COMP_CD, sep = "_")) %>%
  left_join(sectcsv, "SectionIdentifier")

# join stuEnrl2 with drops3
stuenrl_cmbd <- stuEnrl2 %>%
  left_join(drops3, c("CLASS_NUM", "PERSON_SID", "stuPersonID", "instrPersonID"), suffix = c("", ".y")) %>% 
  select_at(
    vars(-ends_with(".y"))
)

# reduce to needed columns and format for CL import
stuenrl_cmbd2 <- stuenrl_cmbd %>%
  select(PersonIdentifier, SectionIdentifier, Status, FirstName, LastName, Email, mtgStartDt, mtgEndDt) %>%
  distinct() %>%
  mutate(mtgStartDt = format(mdy(mtgStartDt), "%Y-%m-%d")) %>%
  mutate(mtgEndDt = format(mdy(mtgEndDt), "%Y-%m-%d")) %>%
  mutate(BeginDate = paste0(mtgStartDt, "T18:00:00-06:00")) %>%
  mutate(EndDate = paste0(mtgEndDt, "T18:00:00-06:00")) %>%
  add_column(Credits = '', GradeOption = '', RegisteredDate = '', InitialCourseGrade = '', StatusChangeDate = '', FinalCourseGrade = '') %>%
  select(PersonIdentifier,SectionIdentifier,Status,FirstName,LastName,Email,Credits,GradeOption,RegisteredDate,BeginDate,EndDate,InitialCourseGrade,StatusChangeDate,FinalCourseGrade) %>%
  mutate(FirstName = case_when(
    is.na(FirstName) ~ '.',
    TRUE ~ FirstName)) %>%
  mutate(LastName = case_when(
    is.na(LastName) ~ '.',
    TRUE ~ LastName))

# NEED TO ACCT FOR DUPS AT THIS STAGE
# where PersonIdentifier and SectionIdentifier both match
# choose Status == 'Enrolled' and remove Status == 'Dropped'
stuenrl_cmbd3 <- stuenrl_cmbd2 %>%
  mutate(dupck = paste0(PersonIdentifier, SectionIdentifier)) %>%
  group_by(dupck) %>%
  filter(n() >= 2) %>%
  ungroup() %>%
  select(-dupck)

# remove DROPPED and keep ENROLLED
stuenrl_cmbd4 <- stuenrl_cmbd3 %>%
  filter(Status == 'Enrolled')

# remove dups
stuenrl_cmbd5 <- anti_join(stuenrl_cmbd2,stuenrl_cmbd3)

# add filtered rows
stuenrl_cmbd6 <- rbind(stuenrl_cmbd5,stuenrl_cmbd4)

# remove DROPPED and keep ENROLLED
stuenrl_cmbd6 <- stuenrl_cmbd6 %>%
  filter(Status == 'Enrolled')

# create file for CL import
write.csv(stuenrl_cmbd6, paste0(import_path, '\\Enrollment\\stuEnrl', term_cd, '__', batch, '.csv'), row.names = FALSE)

# create running cumulative file
enrl_upd <- stuenrl_cmbd6 %>%
  mutate(batch = sess_num)

# import existing log
enrlLog <- read.csv(paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\Enrl_All.csv'))

# add new batch data to existing log
enrl_all <- rbind(enrlLog, enrl_upd)

# update cumulative file
write.csv(enrl_all, paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\Enrl_All.csv'), row.names = FALSE)

# save batch data to CL data_files
save(enrl_upd, file = paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\Enrl_',batch,'.Rdata'))

#########################################################################
# sect attr

# select cols from session to match AND to create Identifier
cl_attr <- clscu3 %>%
  ungroup() %>%
  filter(sect_attr != '') %>%
  mutate(Identifier = paste(TERM_CD, deptOrgID, SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, SSR_COMP_CD, sep = "_")) %>%
  select(Identifier, sect_attr) %>%
  separate_rows(sect_attr, sep = ',') %>%
  rename(Key = sect_attr) %>%
  mutate(Value = Key)

sess_attr <- session %>%
  ungroup() %>%
  mutate(Identifier = paste(TERM_CD, deptOrgID, SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, SSR_COMP_CD, sep = "_")) %>%
  left_join(cl_attr, by = 'Identifier') %>%
  distinct() %>%
  select(Identifier, Key, Value) %>%
  filter(!is.na(Key)) %>%
  distinct()

# cumulative list (import or create if session 1)
file_path <- paste0(import_path, '\\SectionAttribute\\secAttr', term_cd, '.csv')

# Check if the file exists
if (file.exists(file_path)) {
  semqs <- read.csv(file_path)
  # combine current session qs with previous custom qs
  sectattr_total <- rbind(semqs, sess_attr)

} else {
  sectattr_total <- sess_attr
}

# remove dups
sectattr_total <- sectattr_total %>%
  distinct()

# for record keeping/troubleshooting
write.csv(sess_attr, paste0(import_path, '\\SectionAttribute\\secAttr', term_cd, '_', batch, '.csv'), row.names = FALSE)

# create file for CL import
write.csv(sectattr_total, paste0(import_path, '\\SectionAttribute\\secAttr', term_cd, '.csv'), row.names = FALSE)

# create running cumulative file
sectattr_upd <- sess_attr %>%
  mutate(batch = sess_num)

# import existing log
sectattrLog <- read.csv(paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\sectAttr_All.csv'))

# add new batch data to existing log
sectattr_all <- rbind(sectattrLog, sectattr_upd)

# update cumulative file
write.csv(sectattr_all, paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\sectAttr_All.csv'), row.names = FALSE)

# save batch data to CL data_files
save(sectattr_upd, file = paste0(folder, 'CampusLabs\\Data_Files\\', term_cd, '\\sectAttr_All_', batch, '.Rdata'))
