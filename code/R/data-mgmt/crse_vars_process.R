#########################################################################
# Prepare crse_vars doc with late changes
# created: Vince Darcangelo 5/16/24
# most recent update: Vince Darcangelo 8/8/24
# \AIM Measurement - FCQ\R_Code\campus_labs\crse_vars_process.R
#########################################################################

# UPDATE THESE VARS EACH SEMESTER:
term_cd <- 2244
userid <- 'darcange'
setwd(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CampusLabs\\Response_Exports\\', term_cd))

#########################################################################
drv <- dbDriver('Oracle')
connection_string <- '(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)
  (HOST=ciw.prod.cu.edu)(PORT=1525))(CONNECT_DATA=(SERVICE_NAME=CIW)))'
con <- dbConnect(drv, username = getOption('databaseuid'),
  password = getOption('databasepword'), dbname = connection_string)

# pull data from c20 file
crse_vars <- read.csv(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CourseAudit_bak\\', term_cd, '\\c20.csv'))

#########################################################################
# dept changes
#########################################################################

# fix any dept changes
crse_vars <- crse_vars %>%
  mutate(instrEmailAddr = tolower(instrEmailAddr)) %>%
  mutate(fcqdept = case_when(
    fcqdept == 'HUEN' ~ 'ENES',
    TRUE ~ fcqdept
  )) %>%
  mutate(deptOrgID = case_when(
    deptOrgID == 'CUBLD:BLDR:HUEN' ~ 'CUBLD:BLDR:ENES',
    TRUE ~ deptOrgID
  )) %>%
  mutate(spons_AcadOrg = case_when(
    spons_AcadOrg == 'B-HUEN' ~ 'B-ENES',
    TRUE ~ spons_AcadOrg
  )) %>%
  mutate(ACAD_ORG_CD = case_when(
    ACAD_ORG_CD == 'B-HUEN' ~ 'B-ENES',
    TRUE ~ ACAD_ORG_CD
  ))

#########################################################################
# symbol fixes in names
#########################################################################

# instrNm
crse_vars$instrNm <- gsub('<eb>', 'e', crse_vars$instrNm)
crse_vars$instrNm <- gsub('<e1>', 'a', crse_vars$instrNm)
crse_vars$instrNm <- gsub('<f1>', 'n', crse_vars$instrNm)
crse_vars$instrNm <- gsub('<f3>', 'o', crse_vars$instrNm)
crse_vars$instrNm <- gsub('<c1>', 'A', crse_vars$instrNm)
crse_vars$instrNm <- gsub('<fa>', 'u', crse_vars$instrNm)
crse_vars$instrNm <- gsub('<92>', "'", crse_vars$instrNm)
crse_vars$instrNm <- gsub('<99>', '', crse_vars$instrNm)
crse_vars$instrNm <- gsub('<bf>', '', crse_vars$instrNm)

# instrLastNm
crse_vars$instrLastNm <- gsub('<eb>', 'e', crse_vars$instrLastNm)
crse_vars$instrLastNm <- gsub('<e1>', 'a', crse_vars$instrLastNm)
crse_vars$instrLastNm <- gsub('<f1>', 'n', crse_vars$instrLastNm)
crse_vars$instrLastNm <- gsub('<f3>', 'o', crse_vars$instrLastNm)
crse_vars$instrLastNm <- gsub('<c1>', 'A', crse_vars$instrLastNm)
crse_vars$instrLastNm <- gsub('<fa>', 'u', crse_vars$instrLastNm)
crse_vars$instrLastNm <- gsub('<92>', "'", crse_vars$instrLastNm)
crse_vars$instrLastNm <- gsub('<99>', '', crse_vars$instrLastNm)
crse_vars$instrLastNm <- gsub('<bf>', '', crse_vars$instrLastNm)

# instrFirstNm
crse_vars$instrFirstNm <- gsub('<eb>', 'e', crse_vars$instrFirstNm)
crse_vars$instrFirstNm <- gsub('<e1>', 'a', crse_vars$instrFirstNm)
crse_vars$instrFirstNm <- gsub('<f1>', 'n', crse_vars$instrFirstNm)
crse_vars$instrFirstNm <- gsub('<f3>', 'o', crse_vars$instrFirstNm)
crse_vars$instrFirstNm <- gsub('<c1>', 'A', crse_vars$instrFirstNm)
crse_vars$instrFirstNm <- gsub('<fa>', 'u', crse_vars$instrFirstNm)
crse_vars$instrFirstNm <- gsub('<92>', "'", crse_vars$instrFirstNm)
crse_vars$instrFirstNm <- gsub('<99>', '', crse_vars$instrFirstNm)
crse_vars$instrFirstNm <- gsub('<bf>', '', crse_vars$instrFirstNm)

# instrMiddleNm
crse_vars$instrMiddleNm <- gsub('<eb>', 'e', crse_vars$instrMiddleNm)
crse_vars$instrMiddleNm <- gsub('<e1>', 'a', crse_vars$instrMiddleNm)
crse_vars$instrMiddleNm <- gsub('<f1>', 'n', crse_vars$instrMiddleNm)
crse_vars$instrMiddleNm <- gsub('<f3>', 'o', crse_vars$instrMiddleNm)
crse_vars$instrMiddleNm <- gsub('<c1>', 'A', crse_vars$instrMiddleNm)
crse_vars$instrMiddleNm <- gsub('<fa>', 'u', crse_vars$instrMiddleNm)
crse_vars$instrMiddleNm <- gsub('<92>', "'", crse_vars$instrMiddleNm)
crse_vars$instrMiddleNm <- gsub('<99>', '', crse_vars$instrMiddleNm)
crse_vars$instrMiddleNm <- gsub('<bf>', '', crse_vars$instrMiddleNm)

# CRSE_LD
crse_vars$CRSE_LD <- gsub('<eb>', 'e', crse_vars$CRSE_LD)
crse_vars$CRSE_LD <- gsub('<e1>', 'a', crse_vars$CRSE_LD)
crse_vars$CRSE_LD <- gsub('<f1>', 'n', crse_vars$CRSE_LD)
crse_vars$CRSE_LD <- gsub('<f3>', 'o', crse_vars$CRSE_LD)
crse_vars$CRSE_LD <- gsub('<c1>', 'A', crse_vars$CRSE_LD)
crse_vars$CRSE_LD <- gsub('<fa>', 'u', crse_vars$CRSE_LD)
crse_vars$CRSE_LD <- gsub('<92>', "'", crse_vars$CRSE_LD)
crse_vars$CRSE_LD <- gsub('<99>', '', crse_vars$CRSE_LD)
crse_vars$CRSE_LD <- gsub('<bf>', '', crse_vars$CRSE_LD)

# account for pmus crse types
crse_pmus0 <- crse_vars %>%
  filter(spons_fcqdept == 'MB' & SBJCT_CD == 'PMUS' & SSR_COMP_CD == 'STU' & combStat != '')

crse_vars2 <- anti_join(crse_vars, crse_pmus0)

crse_pmus0x <- crse_pmus0 %>%
  filter(combStat == 'S') %>%
  select(-c(totEnrl_nowd, ENRL_TOT))

crse_pmus1 <- crse_pmus0 %>%
  select(instrEmplid, assoc_class_secID, totEnrl_nowd, ENRL_TOT, combStat) %>%
  group_by(instrEmplid, assoc_class_secID) %>%
  summarise(
    totEnrl_nowd = sum(totEnrl_nowd),
    ENRL_TOT = sum(ENRL_TOT))

crse_pmus2 <- crse_pmus0x %>%
  left_join(crse_pmus1, by = c('instrEmplid', 'assoc_class_secID')) %>%
  relocate(totEnrl_nowd, .after = totEnrl_nowd_comb) %>%
  relocate(ENRL_TOT, .before = ENRL_CAP)

crse_vars3 <- rbind(crse_vars2, crse_pmus2)

# create Course_Section_External_ID for matching and filter out blanks
crse_vars4 <- crse_vars3 %>%
  mutate(CATALOG_NBR = as.character(CATALOG_NBR)) %>%
  mutate(Course_Section_External_ID = paste(TERM_CD, tolower(deptOrgID), tolower(SBJCT_CD), tolower(CATALOG_NBR), tolower(CLASS_SECTION_CD), tolower(crseSec_comp_cd), sep = '_')) %>%
  mutate(Instructor_External_ID = paste0(instrConstituentID, '@cu.edu')) %>%
  filter(instrPersonID != '-') %>%
  distinct(Instructor_External_ID, CLASS_NUM, .keep_all=T)

# fix name anomalies
crse_vars5 <- crse_vars4 %>%
  mutate(instrNm = case_when(
    instrPersonID == 'XXXXXXXXX' ~ 'Gonzalez,Alex',
    TRUE ~ instrNm)) %>%
#  mutate(instrLastNm = case_when(
#    TRUE ~ instrLastNm)) %>%
  mutate(instrFirstNm = case_when(
    instrPersonID == 'XXXXXXXXX' ~ 'Alex',
    TRUE ~ instrFirstNm)) %>%
  mutate(across(c(instrNm, instrLastNm, instrFirstNm, instrMiddleNm), gsub, pattern = '<e9>', replacement = 'e')) %>%
  mutate(across(c(instrNm, instrLastNm, instrFirstNm, instrMiddleNm), gsub, pattern = '<ed>', replacement = 'i'))

#########################################################################
# create instructor tables to fill missing IDs at the end of process
bd_inst_table <- crse_vars5 %>%
  filter(INSTITUTION_CD == 'CUBLD') %>%
  distinct(Course_Section_External_ID, instrPersonID, instrNm, Instructor_External_ID, CLASS_NUM, assoc_class_secID, spons_id)

dn_inst_table <- crse_vars5 %>%
  filter(INSTITUTION_CD == 'CUDEN') %>%
  distinct(Course_Section_External_ID, instrPersonID, instrNm, Instructor_External_ID, CLASS_NUM, assoc_class_secID, spons_id)

#########################################################################

# QC inst tables
bd_inst_table_na <- bd_inst_table[!complete.cases(bd_inst_table), ]
dn_inst_table_na <- dn_inst_table[!complete.cases(dn_inst_table), ]

# if bd_inst_table_na and/or dn_inst_table_na > 0, QC fix each as needed
bd_inst_table <- bd_inst_table %>%
  mutate(assoc_class_secID = case_when(
    CLASS_NUM == 33405 ~ 'GEOL-5862-901',
    CLASS_NUM == 38505 ~ 'EDUC-6220-001',
    CLASS_NUM == 42259 ~ 'EDUC_5844_002',
    TRUE ~ assoc_class_secID
  )) %>%
  mutate(spons_id = case_when(
    CLASS_NUM == 33405 ~ 'GEOL-5862-901',
    CLASS_NUM == 38505 ~ 'EDUC-6220-001',
    CLASS_NUM == 42259 ~ 'EDUC_5844_002',
    TRUE ~ spons_id
  ))

# optional: export instr tables to csv
write.csv(bd_inst_table, 'BD_Inst_Table_R.csv', row.names = FALSE)
write.csv(dn_inst_table, 'DN_Inst_Table_R.csv', row.names = FALSE)

#########################################################################
# if changes are needed
#########################################################################
# 1. remove instructor (no swap)
#   a. remove from multi-instructor course
#   b. remove from single-instructor course (e.g., cancel class FCQs)
#########################################################################
# 1a. Remove an instructor from multi-instructor course

# identify instructors to drop
instDrp <- crse_vars %>%
  filter(
    campus %in% ('BD') &
    SBJCT_CD %in% ('SPAN') &
    CATALOG_NBR %in% (3280) &
    CLASS_SECTION_CD %in% ('002') &
    instrEmailAddr %in% ('esther.brown@colorado.edu'))

# remove dropped courses from crse_vars
crse_vars <- anti_join(crse_vars, instDrp)

#########################################################################
# 1b. Remove an instructor from single-instructor course

# identify crse to drop instr from
crseDrp <- crse_vars %>%
  filter(
    campus %in% ('BD') &
    SBJCT_CD %in% ('ITAL') &
    CATALOG_NBR %in% (1010) &
    CLASS_SECTION_CD %in% ('002')
  )

# remove dropped courses from crse_vars
crse_vars <- anti_join(crse_vars, crseDrp)

#########################################################################
# 2. add an instructor (no remove or swap)
#########################################################################

# identify crse to add instr to
crseAdd <- crse_vars %>%
  filter(
    campus %in% ('BD') &
    SBJCT_CD %in% ('RUSS') &
    CATALOG_NBR %in% (1020) &
    CLASS_SECTION_CD %in% (c('001', '002'))
  )

# search for instr being added to class
instAdd <- crse_vars %>%
  filter(tolower(instrEmailAddr) == 'anna.manukyan@colorado.edu') %>%
  select(instrNm, instrLastNm, instrFirstNm, instrMiddleNm, instrPersonID, instrConstituentID, instrEmplid, instrEmailAddr) %>%
  distinct()

##########################################
# if instAdd > 0, run 2a, else skip to 2b ?????

# 2a. instr in c20
# crseAdd <- crse_vars %>%
#   filter(
#     campus %in% ('BD') &
#     SBJCT_CD %in% ('ITAL') &
#     CATALOG_NBR %in% (1010) &
#     CLASS_SECTION_CD %in% ('002')
#   )

# update instr info
# instrAdd2 <- crseAdd %>%
#   mutate(
#     instrNm = instAdd$instrNm,
#     instrLastNm = instAdd$instrLastNm,
#     instrFirstNm = instAdd$instrFirstNm,
#     instrMiddleNm = instAdd$instrMiddleNm,
#     instrPersonID = instAdd$instrPersonID,
#     instrConstituentID = instAdd$instrConstituentID,
#     instrEmplid = instAdd$instrEmplid,
#     instrEmailAddr = instAdd$instrEmailAddr
#   )
# 
 # restore swap to keep file
# crse_vars <- rbind(crse_vars, instrAdd2)

###########################################
# if instAdd == 0, run 2b

# 2b. connect to Oracle database (if needed)
drv <- dbDriver('Oracle')
connection_string <- '(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)
  (HOST=ciw.prod.cu.edu)(PORT=1525))(CONNECT_DATA=(SERVICE_NAME=CIW)))'
con <- dbConnect(drv, username = getOption('databaseuid'), 
  password = getOption('databasepword'), dbname = connection_string)

# pull from PS_D_PERSON as pers (~1 min)
perstbl <- dbGetQuery(con,
  'SELECT PERSON_SID, PERSON_ID, PRF_PRI_NAME, PRF_PRI_LAST_NAME, PRF_PRI_FIRST_NAME, PRF_PRI_MIDDLE_NAME
  FROM PS_D_PERSON'
)

pers <- perstbl %>%
  filter(PERSON_SID != '2147483646') %>%
  group_by(PERSON_SID) %>%
  distinct()

colnames(pers) <- c('PERSON_SID', 'instrPersonID', 'instrNm', 'instrLastNm', 'instrFirstNm', 'instrMiddleNm')

# pull from PS_D_PERSON_EMAIL as em (~20 secs)
em <- dbGetQuery(con,
  'SELECT PERSON_ID, PREF_EMAIL, BLD_EMAIL, CONT_ED_EMAIL, DEN_EMAIL
  FROM PS_D_PERSON_EMAIL'
)

colnames(em) <- c('instrPersonID', 'PREF_EMAIL', 'BLD_EMAIL', 'CONT_ED_EMAIL', 'DEN_EMAIL')

# create instrEmailAddr column based on email columns
em2 <- em %>%
  mutate(instrEmailAddr = case_when(
    PREF_EMAIL != '-' ~ PREF_EMAIL,
    DEN_EMAIL != '-' ~ DEN_EMAIL,
    BLD_EMAIL != '-' ~ BLD_EMAIL,
    CONT_ED_EMAIL != '-' ~ CONT_ED_EMAIL
  ))
em2$instrEmailAddr[is.na(em2$instrEmailAddr)] <- '-'
em2$instrEmailAddr <- gsub('<a0>', '', em2$instrEmailAddr)


em3 <- em2 %>%
  select(instrPersonID, instrEmailAddr)

iCrt <- left_join(pers, em3, by = 'instrPersonID')

# pull from PS_D_PERSON_ATTR as cid (~30 secs)
cid <- dbGetQuery(con, 
  'SELECT PERSON_ID, CONSTITUENT_ID
  FROM PS_D_PERSON_ATTR'
)

colnames(cid) <- c('instrPersonID', 'instrConstituentID')

iCrt2 <- left_join(iCrt, cid, by = 'instrPersonID')

# pull from PS_CU_D_EXT_SYSTEM as hr (~12 secs)
hrtbl <- dbGetQuery(con,
  'SELECT EXTERNAL_SYSTEM, PERSON_SID, EXTERNAL_SYSTEM_ID
  FROM PS_CU_D_EXT_SYSTEM'
)

hr0 <- hrtbl %>%
  filter(EXTERNAL_SYSTEM == 'HR' & PERSON_SID != '2147483646') %>%
  select(-EXTERNAL_SYSTEM)

hr <- unique(hr0)
colnames(hr) <- c('PERSON_SID', 'instrEmplid')

iCrt3 <- left_join(iCrt2, hr, by = 'PERSON_SID')
##########

# filter by instr to be added
instrCreate <- iCrt3 %>%
#  filter(instrLastNm == 'Barsic')
#  filter(PERSON_SID == 1456362)
  filter(tolower(instrEmailAddr) == 'anthony.barsic@colorado.edu')

# arrange for adding to crse_vars
instrCreate2 <- instrCreate %>%
  ungroup() %>%
  select(-PERSON_SID) %>%
#  mutate(instrNm = instrNm_src) %>%
  select(instrNm, instrLastNm, instrFirstNm, instrMiddleNm, instrPersonID, instrConstituentID, instrEmplid, instrEmailAddr)

# update instr info
crseAdd2 <- crseAdd %>%
  mutate(
    instrNm = instrCreate2$instrNm,
    instrLastNm = instrCreate2$instrLastNm,
    instrFirstNm = instrCreate2$instrFirstNm,
    instrMiddleNm = instrCreate2$instrMiddleNm,
    instrPersonID = instrCreate2$instrPersonID,
    instrConstituentID = instrCreate2$instrConstituentID,
    instrEmplid = instrCreate2$instrEmplid,
    instrEmailAddr = instrCreate2$instrEmailAddr
  )

# restore swap to keep file
crse_vars <- rbind(crse_vars, crseAdd2)

#########################################################################
# 3. swap an instructor (both remove and replace)
#   a. 1-for-1 swap, instr in c20
#   b. 1-for-1 swap, instr not in c20
#   c. 2-for-1 swap
#########################################################################

# a. 1-for-1 instr swap (instr in c20)
# pull info for incoming instr
instSwap <- crse_vars %>%
  filter(tolower(instrEmailAddr) == 'nancy.guild@colorado.edu') %>%
  select(instrNm, instrLastNm, instrFirstNm, instrMiddleNm, instrPersonID, instrConstituentID, instrEmplid, instrEmailAddr) %>%
  distinct()

# isolate crse with instr swap
crseSwap <- crse_vars %>%
  filter(
    CLASS_NUM %in% c(33027, 33032) &
    # campus %in% ('BD') &
    # SBJCT_CD %in% ('ECEN') &
    # CATALOG_NBR %in% (4606) &
    # CLASS_SECTION_CD %in% ('012') &
    instrLastNm %in% ('Greening')
  )

# remove swap crse from crse_vars
crse_keep <- anti_join(crse_vars, crseSwap)

# update instr info
crseSwap2 <- crseSwap %>%
  mutate(
    instrNm = instSwap$instrNm,
    instrLastNm = instSwap$instrLastNm,
    instrFirstNm = instSwap$instrFirstNm,
    instrMiddleNm = instSwap$instrMiddleNm,
    instrPersonID = instSwap$instrPersonID,
    instrConstituentID = instSwap$instrConstituentID,
    instrEmplid = instSwap$instrEmplid,
    instrEmailAddr = instSwap$instrEmailAddr
  )

# restore swap to keep file
crse_vars <- rbind(crse_keep, crseSwap2)

# b. 1-for-1 instr swap (instr not in system)
# tk

instSwap <- crse_vars %>%
  mutate(instrNm = case_when(
    assoc_class_secID == 'GEOL-1150-010' & CLASS_SECTION_CD %in% c('012', '013') & instrNum == 2 ~ 'Pinkham,Lydia',
    TRUE ~ instrNm)) %>%
  mutate(instrFirstNm = case_when(
    assoc_class_secID == 'GEOL-1150-010' & CLASS_SECTION_CD %in% c('012', '013') & instrNum == 2 ~ '',
    TRUE ~ instrFirstNm)) %>%
  mutate(instrLastNm = case_when(
    assoc_class_secID == 'GEOL-1150-010' & CLASS_SECTION_CD %in% c('012', '013') & instrNum == 2 ~ '',
    TRUE ~ instrLastNm)) %>%
  mutate(instrMiddleNm = case_when(
    assoc_class_secID == 'GEOL-1150-010' & CLASS_SECTION_CD %in% c('012', '013') & instrNum == 2 ~ '',
    TRUE ~ instrMiddleNm)) %>%
  mutate(instrEmplid = case_when(
    assoc_class_secID == 'GEOL-1150-010' & CLASS_SECTION_CD %in% c('012', '013') & instrNum == 2 ~ '',
    TRUE ~ instrEmplid)) %>%
  mutate(instrPersonID = case_when(
    assoc_class_secID == 'GEOL-1150-010' & CLASS_SECTION_CD %in% c('012', '013') & instrNum == 2 ~ '110212452',
    TRUE ~ instrPersonID)) %>%
  mutate(instrConstituentID = case_when(
    assoc_class_secID == 'GEOL-1150-010' & CLASS_SECTION_CD %in% c('012', '013') & instrNum == 2 ~ 'XXXXXXX-XXXX-11eb-B19E-005056942941',
    TRUE ~ instrConstituentID)) %>%
  mutate(instrEmailAddr = case_when(
    assoc_class_secID == 'GEOL-1150-010' & CLASS_SECTION_CD %in% c('012', '013') & instrNum == 2 ~ 'lydia.pinkham@colorado.edu',
    TRUE ~ instrEmailAddr))


# dealing with 2-for-1 instr swap
# subset, duplicate (bind_rows), change
crse_vars_keep <- crse_vars %>%
  filter(assoc_class_secID != 'ASEN-5052-001' & assoc_class_secID != 'ASEN-5052-001B')
crse_vars_swap <- crse_vars %>%
  filter(assoc_class_secID %in% c('ASEN-5052-001', 'ASEN-5052-001B')) %>% 
  bind_rows(crse_vars_swap)


# 2-for-1 swap
crse_vars_swap <- crse_vars_swap %>%
  mutate(iMatch = c('a', 'a', 'b', 'b')) %>%
  mutate(instrNm = case_when(
    iMatch == 'a' ~ 'Fuentes Munoz,Oscar',
    iMatch == 'b' ~ 'Henry,Damennick')) %>%
  mutate(instrFirstNm = '') %>%
  mutate(instrLastNm = '') %>%
  mutate(instrMiddleNm = '') %>%
  mutate(instrEmplid = '') %>%
  mutate(instrPersonID = case_when(
    iMatch == 'a' ~ 'XXXXXXXXX',
    iMatch == 'b' ~ 'XXXXXXXXX')) %>%
  mutate(instrConstituentID = case_when(
    iMatch == 'a' ~ 'XXXX-11e6-B372-005056945406',
    iMatch == 'b' ~ 'XXXX-11e7-98D6-005056941015')) %>%
  mutate(instrEmailAddr = case_when(
    iMatch == 'a' ~ 'oscar.fuentesmunoz@colorado.edu',
    iMatch == 'b' ~ 'damennick.henry@colorado.edu')) %>%
  mutate(instrNum = case_when(
    iMatch == 'a' ~ 1,
    iMatch == 'b' ~ 2)) %>%
  select(-iMatch)

crse_vars <- rbind(crse_vars_keep2, crse_vars_swap)


# filter for emails
crse_vars_drp <- crse_vars %>%
  filter(grepl(instNames, Email, ignore.case = TRUE))

# filter to remove
inst_mast3 <- inst_mast2 %>%
  filter(LastName != 'Dimaggio')

# filter to swap - pull correct inst info (from other classes)
inst_mast4 <- inst_mast2 %>%
  filter(LastName == 'Barsic') %>%
  select(-SectionIdentifier)

# filter to swap - pull correct class info (removing wrong instr)
inst_mast5 <- inst_mast %>%
  select(SectionIdentifier)

# filter to swap - combine correct info
inst_swapped <- cbind(inst_mast4, inst_mast5)
inst_swapped <- inst_swapped %>%
  select(PersonIdentifier, SectionIdentifier, FirstName, LastName, Email, Role)

# filter for keeps
inst_keep <- inst_mast %>%
  filter(!grepl(instNames, Email, ignore.case = TRUE))

# restore filtered to keep file
inst_keep2 <- rbind(inst_keep, inst_mast3)

# add swapped to keep file
inst_keep3 <- rbind(inst_keep2, inst_swapped)
