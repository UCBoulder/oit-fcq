#############################################################################
# Apply instructor changes, swaps, etc.
# created: Vince Darcangelo, 8/4/22
# most recent update: Vince Darcangelo 4/25/25
# \AIM Measurement - FCQ\R_Code\campus_labs\instCL_change.R
#############################################################################

batchx <- 98
term_cd <- 2254
userid <- 'darcange'

inst_All <- read.csv(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CampusLabs\\Data_Files\\', term_cd, '\\Inst_All.csv'))

instAcct_All <- read.csv(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CampusLabs\\Data_Files\\', term_cd, '\\instAcct_All.csv'))

#############################################################################
# Scenario 1.
# Remove an instructor (no add or swap)
#############################################################################

# for instr add/rem (ex: '(jon.smith@colorado.edu|amy.gomez@colorado.edu))
instNames <- 'manuel.serapio@ucdenver.edu'

# if removing from specific course(s) only, include this
xcrse <- '(2254_CUDEN:BLDR:SLHS_SLHS_5918_001_PRA|2251_CUBLD:BLDR:SLHS_SLHS_5918_002_PRA|2251_CUBLD:BLDR:SLHS_SLHS_5918_003_PRA)'

# filter for emails + crse
if (exists('xcrse')) {
inst_All2 <- inst_All %>%
  filter(grepl(instNames, Email, ignore.case = TRUE)) %>%
  filter(grepl(xcrse, SectionIdentifier, ignore.case = TRUE))
} else {
inst_All2 <- inst_All %>%
  filter(grepl(instNames, Email, ignore.case = TRUE))
}

inst_rem <- inst_All2 %>%
  select(PersonIdentifier, SectionIdentifier)

# filter to remove
inst_All3 <- setdiff(inst_All, inst_All2)

# export updated inst_all data
write.csv(inst_All3, paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CampusLabs\\Data_Files\\', term_cd, '\\Inst_All.csv'), row.names = FALSE)

# export inst_rem file to import to Campus Labs
write.csv(inst_rem, paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CampusLabs\\Imports\\', term_cd, '\\Instructor\\RmvInst', batchx, '.csv'), row.names = FALSE)

# ONLY RUN IF INST IS REMOVED FROM ALL CLASSES
instAcct_All2 <- instAcct_All %>%
  filter(tolower(Email) != instNames)

write.csv(instAcct_All2, paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CampusLabs\\Data_Files\\', term_cd, '\\instAcct_All.csv'))

#############################################################################
# Scenario 2.
# Add an instructor (no remove or swap)
#############################################################################

# for instr add (ex: '(jon.smith@colorado.edu|amy.gomez@colorado.edu))
instNames <- 'adam.kaufman@Colorado.edu'

# if removing from specific course(s) only, include this
xcrse <- toupper('2251_cubld:bldr:phys_phys_7560_001_lec')

# filter for defined vars
em2 <- em %>%
  filter(grepl(instNames, PREF_EMAIL, ignore.case = TRUE))

# join with acctid
acct01 <- left_join(em2, acctid, by = 'instrPersonID')

# join with acct01
acct02 <- left_join(acct01, cid, by = 'instrPersonID')

acct03 <- acct02 %>%
  ungroup() %>%
  mutate(id = paste0(instrConstituentID, '@cu.edu')) %>%
  select(id, LAST_NAME, FIRST_NAME, PREF_EMAIL)
#  select(id, LAST_NAME, FIRST_NAME, BLD_EMAIL)

# renames columns
colnames(acct03) <- c('PersonIdentifier', 'LastName', 'FirstName', 'Email')

# fill in remaining columns
inst_All2 <- acct03 %>%
  mutate(SectionIdentifier = xcrse) %>%
  mutate(Role = 'Primary') %>%
  mutate(batch = batchx) %>%
  select(PersonIdentifier, SectionIdentifier, FirstName, LastName, Email, Role, batch)

# add to inst_All master
inst_Add <- rbind(inst_All, inst_All2)

# export updated inst_all data
write.csv(inst_Add, paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CampusLabs\\Data_Files\\', term_cd, '\\Inst_All.csv'), row.names = FALSE)

# format for instAcct_All
instAcct_All2 <- acct03 %>%
  mutate(batch = batchx) %>%
  select(PersonIdentifier, FirstName, LastName, Email, batch)

# add to instAcct_All master
instAcct_All_Add <- rbind(instAcct_All, instAcct_All2)

# export updated inst_all data
write.csv(instAcct_All_Add, paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CampusLabs\\Data_Files\\', term_cd, '\\instAcct_All.csv'), row.names = FALSE)

#########################################################################

# 3. Swap an instructor (both remove and replace)
#  a. 1-for-1 swap (instr in c20)
#  b. 1-for-1 swap (instr !in c20)
#  c. 2-for-1 swap

#########################################################################

# 3a. 1-for-1 swap (instr in c20)

#########################################################################

# 3b. 1-for-1 swap (instr !in c20)

# for instr to ADD (ex: '(jon.smith@colorado.edu|amy.gomez@colorado.edu))
inst_Add <- 'haley.kenyon@colorado.edu'

# for instr to REM (ex: '(jon.smith@colorado.edu|amy.gomez@colorado.edu))
inst_Rem <- 'kathryn.grabenstein@colorado.edu'

# if removing from specific course(s) only, include this
xcrse <- '2244_CUBLD:CEPS:BBAC_EBIO_4100_751_LEC'

##########################################################################
# pull missing inst info from UIS
# connect to Oracle database
drv <- dbDriver('Oracle')
connection_string <- '(DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)
  (HOST=ciw.prod.cu.edu)(PORT=1525))(CONNECT_DATA=(SERVICE_NAME=CIW)))'
con <- dbConnect(drv, username = getOption('databaseuid'), 
  password = getOption('databasepword'), dbname = connection_string)

# pull from PS_D_PERSON_EMAIL as em
em <- dbGetQuery(con,
  'SELECT PERSON_ID, PREF_EMAIL, BLD_EMAIL, CONT_ED_EMAIL, DEN_EMAIL
  FROM PS_D_PERSON_EMAIL'
)

colnames(em) <- c('instrPersonID', 'PREF_EMAIL', 'BLD_EMAIL', 'CONT_ED_EMAIL', 'DEN_EMAIL')

# filter for defined vars
em2 <- em %>%
  filter(grepl(inst_Add, PREF_EMAIL, ignore.case = TRUE))

# pull from PS_D_PERSON data as acctid
acctid <- dbGetQuery(con,
  'SELECT PERSON_ID, PRF_PRI_LAST_NAME, PRF_PRI_FIRST_NAME
  FROM PS_D_PERSON'
)

colnames(acctid) <- c('instrPersonID', 'LAST_NAME', 'FIRST_NAME')

acct01 <- left_join(em2, acctid, by = 'instrPersonID')

# pull from PS_D_PERSON_ATTR as cid
cid <- dbGetQuery(con, 
  'SELECT PERSON_ID, CONSTITUENT_ID
  FROM PS_D_PERSON_ATTR'
)

colnames(cid) <- c('instrPersonID', 'instrConstituentID')

# join with acct01
acct02 <- left_join(acct01, cid, by = 'instrPersonID')

acct03 <- acct02 %>%
  ungroup() %>%
  mutate(id = paste0(instrConstituentID, '@cu.edu')) %>%
  select(id, LAST_NAME, FIRST_NAME, PREF_EMAIL)
#  select(id, LAST_NAME, FIRST_NAME, BLD_EMAIL)

# renames columns
colnames(acct03) <- c('PersonIdentifier', 'LastName', 'FirstName', 'Email')
##########################################################################

# swap inst

# filter for emails + crse
inst_All2 <- inst_All %>%
  filter(grepl(inst_Rem, Email, ignore.case = TRUE)) %>%
  filter(grepl(xcrse, SectionIdentifier, ignore.case = TRUE))

# isolate cols
inst_All3 <- inst_All2 %>%
  select(SectionIdentifier, Role) %>%
  mutate(batch = as.integer(batchx))

# replace
inst_correct <- cbind(inst_All3, acct03)

# fixed row
inst_correct2 <- inst_correct %>%
  select(PersonIdentifier, SectionIdentifier, FirstName, LastName, Email, Role, batch)

# filter to remove
inst_All4 <- setdiff(inst_All, inst_All2)

inst_Fixed <- rbind(inst_All4, inst_correct2)

# update instAcct_All file as well
inst_correct3 <- inst_correct2 %>%
  select('PersonIdentifier', 'FirstName', 'LastName', 'Email', 'batch')
  
# instAcct_All
instAcct_All2 <- rbind(instAcct_All, inst_correct3)

# export updated inst_all data
write.csv(inst_Fixed, paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CampusLabs\\Data_Files\\', term_cd, '\\Inst_All.csv'), row.names = FALSE)

# export inst_rem file to import to Campus Labs
write.csv(instAcct_All2, paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CampusLabs\\Data_Files\\', term_cd, '\\instAcct_All.csv'), row.names = FALSE)
