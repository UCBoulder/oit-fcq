##########################################################################
# Setup folders/files for Campus Labs new semester
# created: Vince Darcangelo 12/19/22
# most recent update: Vince Darcangelo 8/12/25
# \OneDrive - UCB-O365\Documents\oit-fcq\code\R\account-mgmt\CL_New_Sem_Setup.R
##########################################################################
# set date and term
userid <- 'darcange'
folder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\')
import_folder <- paste0(folder, 'CampusLabs\\Imports\\')

entrydt <- Sys.Date()
entrydt <- format(entrydt, format = '%Y%m%d')

# update vars
term_cd <- 2257
yr <- 2025

# set the term based on 1 = spring, 4 = summer, 7 = fall
sem147 <- 7

if (sem147 == 1) {
  sem <- 'Spring'
  bgdt <- '-01-01T17:00:00-07:00'
  endt <- '-05-31T17:00:00-07:00'
} else if (sem147 == 4) {
  sem <- 'Summer'
  bgdt <- '-05-01T17:00:00-07:00'
  endt <- '-08-31T17:00:00-07:00'
} else if (sem147 == 7) {
  sem <- 'Fall'
  bgdt <- '-08-01T17:00:00-07:00'
  endt <- '-12-31T17:00:00-07:00'
}

######################################################################### create folders for CL import files
dir.create(paste0(import_folder,term_cd))
dir.create(paste0(import_folder,term_cd,'\\AcademicTerm'))
dir.create(paste0(import_folder,term_cd,'\\Accounts'))
dir.create(paste0(import_folder,term_cd,'\\Course'))
dir.create(paste0(import_folder,term_cd,'\\Section'))
dir.create(paste0(import_folder,term_cd,'\\Enrollment'))
dir.create(paste0(import_folder,term_cd,'\\Instructor'))
dir.create(paste0(import_folder,term_cd,'\\OrgUnit'))
dir.create(paste0(import_folder,term_cd,'\\SectionAttribute'))

#########################################################################
# term22xx_row1.csv - import first!!!!!
aterm_row1 <- data.frame(
TermIdentifier = term_cd,
Name = paste(sem, yr, sep = ' '),
BeginDate = paste0(yr,bgdt),
EndDate = paste0(yr,endt),
ParentIdentifier = '',
Type = 'Semester'
)

write.csv(aterm_row1, paste0(import_folder, term_cd, '\\AcademicTerm\\term', term_cd, '_row1.csv'), row.names = FALSE)

###################################
# term22xx.csv
aterm <- data.frame(
TermIdentifier = 
  c(paste0(term_cd, ':CUBLD:BLDR'),
    paste0(term_cd, ':CUBLD:BLD3'),
    paste0(term_cd, ':CUBLD:CEPS'),
    paste0(term_cd, ':CUDEN')),
Name = 
  c(paste(sem, yr, 'CU Boulder main campus semester', sep = ' '),
    paste(sem, yr, 'CU Boulder distance semester', sep = ' '),
    paste(sem, yr, 'CU Boulder Continuing Education', sep = ' '),
    paste(sem, yr, 'CU Denver semester', sep = ' ')),
BeginDate = paste0(yr,bgdt),
EndDate = paste0(yr,endt),
ParentIdentifier = term_cd,
Type = 'Intersession'
)

write.csv(aterm, paste0(import_folder, term_cd, '\\AcademicTerm\\term', term_cd, '.csv'), row.names = FALSE)

#######################################################################
# create cumulative CL files

# create folder for new term in CL data_files
dir.create(paste0(folder, '\\CampusLabs\\Data_Files\\', term_cd))

# instAcct_All
iAcct <- setNames(data.frame(matrix(ncol = 5, nrow = 0)), c('PersonIdentifier', 'FirstName', 'LastName', 'Email', 'batch'))

write.csv(iAcct, paste0(folder, '\\CampusLabs\\Data_Files\\', term_cd, '\\instAcct_All.csv'), row.names = FALSE)

# stuAcct_All
sAcct <- setNames(data.frame(matrix(ncol = 5, nrow = 0)), c('PersonIdentifier', 'FirstName', 'LastName', 'Email', 'batch'))

write.csv(sAcct, paste0(folder, '\\CampusLabs\\Data_Files\\', term_cd, '\\stuAcct_All.csv'), row.names = FALSE)

# Crse_All
crsAll <- setNames(data.frame(matrix(ncol = 10, nrow = 0)), c('CourseIdentifier', 'Subject', 'Number', 'Title', 'Credits', 'OrgUnitIdentifier', 'Type', 'Description', 'CIPCode', 'batch'))

write.csv(crsAll, paste0(folder, '\\CampusLabs\\Data_Files\\', term_cd, '\\Crse_All.csv'), row.names = FALSE)

# Sect_All
sectAll <- setNames(data.frame(matrix(ncol = 16, nrow = 0)), c('SectionIdentifier', 'TermIdentifier', 'CourseIdentifier', 'Subject', 'CourseNumber', 'Number', 'BeginDate', 'EndDate', 'OrgUnitIdentifier', 'Title', 'Credits', 'DeliveryMode', 'Location', 'Description', 'CrossListingIdentifier', 'batch'))

write.csv(sectAll, paste0(folder, '\\CampusLabs\\Data_Files\\', term_cd, '\\Sect_All.csv'), row.names = FALSE)

# Inst_All
instAll <- setNames(data.frame(matrix(ncol = 7, nrow = 0)), c(
'PersonIdentifier', 'SectionIdentifier', 'FirstName', 'LastName', 'Email', 'Role', 'batch'))

write.csv(instAll, paste0(folder, '\\CampusLabs\\Data_Files\\', term_cd, '\\Inst_All.csv'), row.names = FALSE)

# Enrl_All
enrlAll <- setNames(data.frame(matrix(ncol = 15, nrow = 0)), c(
'PersonIdentifier', 'SectionIdentifier', 'Status', 'FirstName', 'LastName', 'Email', 'Credits', 'GradeOption', 'RegisteredDate', 'BeginDate', 'EndDate', 'InitialCourseGrade', 'StatusChangeDate', 'FinalCourseGrade', 'batch'))

write.csv(enrlAll, paste0(folder, '\\CampusLabs\\Data_Files\\', term_cd, '\\Enrl_All.csv'), row.names = FALSE)

# sectAttr_All
sectAttr_All <- setNames(data.frame(matrix(ncol = 4, nrow = 0)), c(
'Identifier', 'Key', 'Value', 'batch'))

write.csv(sectAttr_All, paste0(folder, '\\CampusLabs\\Data_Files\\', term_cd, '\\sectAttr_All.csv'), row.names = FALSE)

#######################################################################
# create folder for CourseAudit_bak files

# create folder for new term in CL data_files
dir.create(paste0(folder, '\\CourseAudit_bak\\', term_cd))
