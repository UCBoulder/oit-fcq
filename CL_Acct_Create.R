#########################################################################
# Create CL accounts for new admins/chairs not in system
# created: Vince Darcangelo 9/7/22
# most recent update: Vince Darcangelo 8/1/24
# \AIM Measurement - Documents\FCQ\R_Code\campus_labs\CL_Acct_Create.R 
#########################################################################

##################################################################
#'* run ciwpass.R to load ciw credentials *
##################################################################

##################################################################
#'* input needed variables *
##################################################################
term_cd <- 2254
userid <- 'darcange'
folder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\')
import_path <- paste0(folder, 'CampusLabs//Imports//', term_cd)

entrydt <- Sys.Date()
tday <- format(entrydt, format = '%m%d%y')

# search by email
# format example: '(jocelyn.gray@colorado.edu|dawn.savage@ucdenver.edu)'
#nm_display <- '(Crystal Baker|Sarah Mcgarry)'
email <- '(angela.stansbury@colorado.edu|amelia.tubbs@ucdenver.edu|rachel.montgomery@colorado.edu|lucinda.bliss@ucdenver.edu|heather.michener@colorado.edu|evan.shelton@ucdenver.edu)'
# if there are duplicate emails, go to CU-SIS > Course and Class > Instructor/Advisor > Add/Update a Person and enter PERSON_ID into ID field to search -- this may occur if someone went from student to staff

# OR search by last name (be sure to update em2 call below)
#lastnm <- 'Tubbs'
#firstnm <- 'Amelia'
#persid <- '810365613'

# OR search by full name
# fullnm <- c('Tubbs, Amelia', 'Montgomery, Rachel', 'Shipman, Julia', 'Bliss, Lucinda')

#################################################################
#'* search for accounts *
#################################################################
# connect to Oracle database (if needed)
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
  filter(grepl(email, PREF_EMAIL, ignore.case = TRUE))
#  filter(instrPersonID == persid)
#  filter(grepl(email, DEN_EMAIL, ignore.case = TRUE))

# pull from PS_D_PERSON data as acctid
acctid <- dbGetQuery(con,
  'SELECT PERSON_ID, PRF_PRI_LAST_NAME, PRF_PRI_FIRST_NAME
  FROM PS_D_PERSON'
)

colnames(acctid) <- c('instrPersonID', 'LAST_NAME', 'FIRST_NAME')

# a2 <- acctid %>%
#   filter(grepl(lastnm, LAST_NAME, ignore.case = TRUE))
#   filter(FIRST_NAME == 'Sarah')

acct01 <- left_join(em2, acctid, by = 'instrPersonID')

# pull from PS_D_PERSON_ATTR as cid
cid <- dbGetQuery(con, 
  'SELECT PERSON_ID, CONSTITUENT_ID
  FROM PS_D_PERSON_ATTR'
)

colnames(cid) <- c('instrPersonID', 'instrConstituentID')

# join with acct01
acct02 <- left_join(acct01, cid, by = 'instrPersonID')

# join with acct_last
# acct02 <- left_join(acct_last, cid, by = 'PERSON_ID')

# acct03 <- cid %>%
#   filter(PERSON_ID %in% c(109018075, 102575684))
# acct04 <- acct03 %>%
#   left_join(acctid, by = 'PERSON_ID')
# acct05 <- acct04 %>%
#   left_join(em, by = 'PERSON_ID')

# format id and select/order columns
acct03 <- acct02 %>%
  ungroup() %>%
  mutate(id = paste0(instrConstituentID, '@cu.edu')) %>%
  select(id, LAST_NAME, FIRST_NAME, PREF_EMAIL)
#  select(id, LAST_NAME, FIRST_NAME, BLD_EMAIL)

# renames columns
colnames(acct03) <- c('PersonIdentifier', 'LastName', 'FirstName', 'Email')

# output csv for uploading to CL
write.csv(acct03, paste0(import_path, '\\Accounts\\Acct_Add_', tday, '.csv'), row.names = FALSE)

#########################################################################
# DO NOT RUN - HOLD FOR FUTURE EXP
#########################################################################
# exp: pull from PS_CU_D_NAMES_II
exp <- dbGetQuery(con,
  'SELECT EMPLID, LAST_NAME, FIRST_NAME, NAME_DISPLAY, LASTUPDDTTM, CURRENT_IND
  FROM SYSADM.PS_CU_D_NAMES_II'
)

colnames(exp) <- c('instrPersonID', 'LAST_NAME', 'FIRST_NAME', 'NAME_DISPLAY', 'LASTUPDDTTM', 'CURRENT_IND')

exp2 <- exp %>%
  left_join(cid, by = 'instrPersonID') %>%
  filter(CURRENT_IND == 'Y')

exp3 <- exp2 %>%
  left_join(em, by = 'instrPersonID') %>%
  filter(!is.na(PREF_EMAIL))

exp4 <- exp3 %>%
  filter(grepl(email, PREF_EMAIL, ignore.case = TRUE))

####################################

exp3 <- exp2 %>%
  group_by(instrPersonID) %>%
  filter(CURRENT_IND == 'Y') %>%
  filter(LASTUPDDTTM == max(LASTUPDDTTM))

# join with em
acct01 <- left_join(exp3, em, by = 'instrPersonID')

#############################
# search by last name
acct_last <- acctid %>%
#  filter(PRF_PRI_LAST_NAME %in% lastnm)
#  filter(PERSON_ID == '103377611')
  filter(PRF_PRI_LAST_NAME == 'McGarry')
#############################

