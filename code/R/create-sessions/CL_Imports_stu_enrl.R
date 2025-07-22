#########################################################################
# Late student adds to class roster (e.g., after admin was set up.
# created: Vince Darcangelo 2/19/24
# most recent update: Vince Darcangelo 2/19/24
# \AIM Measurement - FCQ\R_Code\campus_labs\CL_Imports_stu_enrl.R
#########################################################################

userid <- 'darcange'
term_cd <- 2241
batch <- '99'

# pull from PS_F_CLASS_ENRLMT as enr (~2 mins)
enrtbl <- dbGetQuery(con,
  'SELECT ENRLMT_STAT_SID, ENRLMT_DROP_DT_SID, DATA_ORIGIN, CLASS_SID, PERSON_SID, ACAD_PROG_SID, GRADE_DT, CRSE_GRADE_OFF
  FROM PS_F_CLASS_ENRLMT'
)

enr <- enrtbl %>%
  filter(ENRLMT_STAT_SID == '3' & ENRLMT_DROP_DT_SID == 19000101 
         & DATA_ORIGIN == 'S') %>%
  select(CLASS_SID)

enr <- enr %>% count(CLASS_SID)
colnames(enr) <- c('CLASS_SID', 'totEnrl')


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
write.csv(stuenrl_cmbd6, paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CampusLabs\\Imports\\', term_cd, '\\Enrollment\\stuEnrl', term_cd, '__', batch, '.csv'), row.names = FALSE)

# create running cumulative file
enrl_upd <- stuenrl_cmbd6 %>%
  mutate(batch = sess_num)

# import existing log
enrlLog <- read.csv(paste0('C:\\Users\\', userid, '\\UCB-o365\\AIM Measurement - FCQ\\CampusLabs\\Data_Files\\', term_cd, '\\Enrl_All.csv'))

# add new batch data to existing log
enrl_all <- rbind(enrlLog, enrl_upd)

# update cumulative file
write.csv(enrl_all, paste0('C:\\Users\\', userid, '\\UCB-o365\\AIM Measurement - FCQ\\CampusLabs\\Data_Files\\', term_cd, '\\Enrl_All.csv'), row.names = FALSE)

# save batch data to CL data_files
save(enrl_upd, file = paste0('C:\\Users\\', userid, '\\UCB-o365\\AIM Measurement - FCQ\\CampusLabs\\Data_Files\\', term_cd, '\\Enrl_',batch,'.Rdata'))
