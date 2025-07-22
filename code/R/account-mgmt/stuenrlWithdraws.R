#########################################################################
# Search for student withdrawals/late drops, import to CL enrl to remove
# created: Vince Darcangelo 8/8/23
# most recent update: Vince Darcangelo 7/18/25
# \AIM Measurement - FCQ\R_Code\campus_labs\stuenrlWithdraws.R
#########################################################################

term_cd <- '2251'
userid <- 'darcange'
dt_beg <- '202501'
dt_end <- '202505'
rundt <- Sys.Date()
rundt2 <- format(rundt, format = '%m%d%y')

# pull from PS_F_CLASS_ENRLMT as studrp
studrp <- dbGetQuery(con,
  'SELECT TERM_SID, CLASS_NUM, CLASS_SID, PERSON_SID, ENRLMT_STAT_SID, ENRLMT_DROP_DT_SID, ACAD_PROG_SID, GRADE_DT, CRSE_GRADE_OFF
  FROM PS_F_CLASS_ENRLMT'
)

# pull only enrolled
studrp2 <- studrp %>%
  filter(ENRLMT_DROP_DT_SID <= 19000101 & CRSE_GRADE_OFF != 'W')

# pull only dropped and withdrawn
studrp2x <- studrp %>%
  filter(CRSE_GRADE_OFF == 'W') %>%
  mutate(DROP_DT = substr(ENRLMT_DROP_DT_SID, 1, 6)) %>%
  filter(DROP_DT >= dt_beg & DROP_DT <= dt_end)

#%>%
#  filter(CLASS_SID == 3019224)

# import Crse_All file if clscu3 isn't available -- or rerun audit
clscu3 <- read.csv(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CourseAudit_bak\\', term_cd, '\\clscu_r.csv'))

# join with clscu3
studrp2xx <- studrp2x %>%
  left_join(clscu3, 'CLASS_NUM') %>%
  filter(fcqStDt != '-') %>%
  filter(adminInd == 1)

# Pull from PS_D_PERSON as pers
perstbl <- dbGetQuery(con,
  'SELECT PERSON_SID, PERSON_ID, PRF_PRI_NAME, PRF_PRI_LAST_NAME, PRF_PRI_FIRST_NAME, PRF_PRI_MIDDLE_NAME
  FROM PS_D_PERSON'
)

pers <- perstbl %>%
  filter(PERSON_SID != '2147483646') %>%
  group_by(PERSON_SID) %>%
  distinct()

colnames(pers) <- c('PERSON_SID', 'PersonID', 'Nm_src', 'LastNm', 'FirstNm', 'MiddleNm')

studrp3 <- studrp2xx %>%
  left_join(pers, 'PERSON_SID')

studrp4 <- studrp3 %>%
  left_join(cid, by = c('PersonID' = 'instrPersonID'))

studrp5 <- studrp4 %>%
  left_join(em, by = c('PersonID' = 'instrPersonID'))

studrp6 <- studrp5 %>%
  mutate(stuConstituentID = paste0(instrConstituentID.y, '@cu.edu')) %>%
  mutate(instrConstituentID = paste0(instrConstituentID.x, '@cu.edu')) %>%
  mutate(Status = 'Dropped') %>%
  mutate(SectionIdentifier = paste0(term_cd,'_',deptOrgID,'_',SBJCT_CD,'_',CATALOG_NBR,'_',CLASS_SECTION_CD,'_',SSR_COMP_CD))

# reduce to match columns
studrp7 <- studrp6 %>%
  ungroup() %>%
  select(stuConstituentID, SectionIdentifier, Status, FirstNm, LastNm, PREF_EMAIL, mtgStartDt, mtgEndDt, GRADE_DT) %>%
  filter(stuConstituentID != 'NA@cu.edu') %>%
  filter(mtgStartDt != '-') %>%
  mutate(mtgStartDt = format(mdy(mtgStartDt), "%Y-%m-%d")) %>%
  mutate(mtgEndDt = format(mdy(mtgEndDt), "%Y-%m-%d")) %>%
  mutate(BeginDate = paste0(mtgStartDt, "T18:00:00-06:00")) %>%
  mutate(EndDate = paste0(mtgEndDt, "T18:00:00-06:00")) %>%
  mutate(across('GRADE_DT', str_replace, ' ', 'T')) %>%
  mutate(Credits = '') %>%
  mutate(GradeOption = '') %>%
  mutate(RegisteredDate = '') %>%
  mutate(InitialCourseGrade = '') %>%
  mutate(FinalCourseGrade = '')

finaldrp <- studrp7 %>%
  select(stuConstituentID, SectionIdentifier, Status, FirstNm, LastNm, PREF_EMAIL, Credits, GradeOption, RegisteredDate, BeginDate, EndDate, InitialCourseGrade, GRADE_DT, FinalCourseGrade) %>%
  unique()

colnames(finaldrp) <- c('PersonIdentifier', 'SectionIdentifier', 'Status', 'FirstName', 'LastName', 'Email', 'Credits', 'GradeOption', 'RegisteredDate', 'BeginDate', 'EndDate', 'InitialCourseGrade', 'StatusChangeDate', 'FinalCourseGrade')

# export
write.csv(finaldrp, paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CampusLabs\\Imports\\', term_cd, '\\Enrollment\\finaldrp', rundt2, '.csv'), row.names = FALSE)
