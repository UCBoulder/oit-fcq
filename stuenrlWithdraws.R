#########################################################################
# Search for student withdrawals/late drops, import to CL enrl to remove
# created: Vince Darcangelo 8/8/23
# most recent update: Vince Darcangelo 12/16/24
# \AIM Measurement - Documents\FCQ\R_Code\campus_labs\stuenrlWithdraws.R
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

#########################################################################
# ignore below - test code
#########################################################################

# fixing prev sems
hx_drps <- read.csv('L:\\mgt\\FCQ\\CampusLabs\\Data_Files\\2231\\Drp_2731.csv')

bd_27 <- read.csv('L:\\mgt\\FCQ\\CampusLabs\\Response_Exports\\2227\\BD_raw.csv')

hx_drps2 <- hx_drps %>%
  unique() %>%
  mutate(Course_Section_External_ID = tolower(SectionIdentifier)) %>%
  mutate(Student_Identifier = PersonIdentifier) %>%
  select(Student_Identifier, Course_Section_External_ID, Status)

hx_27 <- bd_27 %>%
  select(Student_Identifier, Course_Section_External_ID, Instructor_External_ID) %>%
  inner_join(hx_drps2, by = c('Student_Identifier', 'Course_Section_External_ID')) %>%
  unique()

hx_27 <- bd_comb3 %>%
  inner_join(hx_drps2, by = c('Student_Identifier', 'Course_Section_External_ID')) %>%
  unique()

write.csv(hx_27, 'L:\\mgt\\FCQ\\CampusLabs\\Data_Files\\Drp_fix.csv')

bx_2227 <- bd_comb0 %>%
  inner_join(hx_drps2, by = c('Student_Identifier', 'Course_Section_External_ID')) %>%
  unique()

write.csv(bx_2227, 'L:\\mgt\\FCQ\\CampusLabs\\Data_Files\\Drp_fix_bd27.csv')

dx_2227 <- dn_comb2 %>%
  inner_join(hx_drps2, by = c('Student_Identifier', 'Course_Section_External_ID')) %>%
  unique()

write.csv(dx_2227, 'L:\\mgt\\FCQ\\CampusLabs\\Data_Files\\Drp_fix_dx27.csv')

d27 <- dx_2227 %>%
  select(Course_Section_External_ID, Instructor, Q01, Q02, Q03, Q04, Q05, Q06, Q07, Q08, Q09, Q10, Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18, Q19, Q20, Q21, Q22) %>%
  mutate(across(Q01:Q22, ~ na_if(., 0))) %>%
  mutate(across(Q01:Q22, ~replace(.x, is.nan(.x), ''))) %>%
  unite('vals', Q01:Q22, sep = ',', remove = FALSE, na.rm = FALSE)

#d27_mast <- read.xlsx('C:\\Users\\darcange\\OneDrive - UCB-O365\\UCB\\Desktop\\d27_ck.xlsx')
colnames(d27_mast) <- c('Course_Section_External_ID', 'Instructor', 'Q01', 'Q02', 'Q03', 'Q04', 'Q05', 'Q06', 'Q07', 'Q08', 'Q09', 'Q10', 'Q11', 'Q12', 'Q13', 'Q14', 'Q15', 'Q16', 'Q17', 'Q18', 'Q19', 'Q20', 'Q21', 'Q22', 'vals')

d27_join <- d27 %>%
  inner_join(d27_mast, by = c('Course_Section_External_ID', 'vals')) %>%
  unique() %>%
  filter(!row_number() %in% c(77, 78)) %>%
  select(Course_Section_External_ID, Instructor.y, vals)

write.csv(d27_join, paste0('C:\\Users\\', userid, '\\OneDrive - UCB-O365\\FCQ - AIM_ Measurement\\CourseAudit_bak\\', term_cd, '\\d27_join.csv'))