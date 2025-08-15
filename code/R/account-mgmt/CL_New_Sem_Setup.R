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
cq_folder <- paste0(folder, 'FCQ_CustomQs\\')
task_folder <- paste0(folder, 'FCQ_Primer\\Task_Lists\\')
admin_folder <- paste0(folder, 'ReportAdmins\\')

entrydt <- Sys.Date()
entrydt <- format(entrydt, format = '%Y%m%d')

# update vars
prev_term <- 2254
term_cd <- 2257
yr <- 2025

# set sem147 var (term number) based on 1 = spring, 4 = summer, 7 = fall
if (grepl('1$', term_cd)) {
  sem147 <- 1
} else if (grepl('4$', term_cd)) {
  sem147 <- 4
} else if (grepl('7$', term_cd)) {
  sem147 <- 7
}

# set semester, begin and end date vars based on sem147
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

#########################################################################
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
dir.create(paste0(folder, '\\CourseAudit_bak\\', term_cd))

# create folder for previous semester course audit files
dir.create(paste0('G:\\My Drive\\Course_Audit\\Previous_Semesters\\', prev_term))

#######################################################################
# create new custom questions doc from existing doc
cq_file_prev <- paste0(cq_folder, 'GrpCustomQRequests_', prev_term, '.xlsx')

cq_file_new <- paste0(cq_folder, 'GrpCustomQRequests_', term_cd, '.xlsx')

# copy file
file.copy(from = cq_file_prev, to = cq_file_new)

# move cq_file_prev to archive
file.rename(from = cq_file_prev, to = paste0(cq_folder, 'archive\\GrpCustomQRequests_', prev_term, '.xlsx'))

# clean up duplicated file by clearing previously added/removed questions as needed

#######################################################################
# create new task list doc from existing doc
task_prev <- paste0(task_folder, prev_term, '_Task_List.xlsx')

task_new <- paste0(task_folder, term_cd, '_Task_List.xlsx')

# copy file
file.copy(from = task_prev, to = task_new)

# clean up duplicated file by clearing previously tasks as needed

#######################################################################
# create new report admin list doc from existing doc
admin_prev <- paste0(admin_folder, 'Report_Admin_List_', prev_term, '.xlsx')

admin_new <- paste0(admin_folder, 'Report_Admin_List_', term_cd, '.xlsx')

# copy file
file.copy(from = admin_prev, to = admin_new)

# move cq_file_prev to archive
file.rename(from = admin_prev, to = paste0(cq_folder, 'archived_lists\\Report_Admin_List_', prev_term, '.xlsx'))

# clean up duplicated file by removing excess tabs and updating term

#######################################################################
# create folder for semester Communications
dir.create(paste0(folder, '\\Communications\\', term_cd))


# create communication files
fcq_comm_sched <- data.frame(
  Term = paste(sem, yr, sep = ' '),
  Sent_Date = '',
  Memo = c('Registrar (combsect) memo', 'Welcome memo', 'Course Audit info', 'Course Audit open', 'Course Audit close', 'Final admin pre - Boulder', 'Final admin pre - Denver', 'Final admin pre - Anschutz', 'Initial results', 'Batch reports', 'Final reports', 'Flagging report - Boulder OIEC', 'Flagging report - Denver OIE', 'Flagging report - Anschutz OIE'),
  Type = c('General', 'General', 'Audit', 'Audit', 'Audit', 'Final', 'Final', 'Final', 'Reports', 'Reports', 'Reports', 'Flagging', 'Flagging', 'Flagging'),
  Due_Date = c('First week of semester', 'First week of semester', 'Monday of the week the audit opens', 'Wednesday of the week the audit opens', 'Wednesday of the week the audit closes', 'Week before final admin opens (Thursday or Friday)', 'Week before final admin opens (Thursday or Friday)', 'Week before final admin opens (Thursday or Friday)', 'Week before results will be available in platform', 'When batch reports become available', 'When all reports have been updated/posted', 'When flagged items are ready to submit', 'When flagged items are ready to submit', 'When flagged items are ready to submit'),
  Audience = c('Registrars (all)', 'FCQ coordinators (all)', 'FCQ coordinators (all)', 'FCQ coordinators (all)', 'FCQ coordinators (all)', 'Boulder FCQ coordinators, faculty, students', 'Denver FCQ coordinators, faculty, students', 'Anschutz FCQ coordinators, faculty, students', 'FCQ coordinators, faculty (all)', 'FCQ coordinators (all)', 'FCQ coordinators (all)', 'Boulder OIEC', 'Denver OIE', 'Anschutz OIE'),
  Source = c('Communications folder', 'Communications folder', 'Communications folder', 'Communications folder', 'Communications folder', 'Campus Labs/Anthology', 'Campus Labs/Anthology', 'Campus Labs/Anthology', 'Campus Labs/Anthology', 'Communications folder', 'Communications folder', 'Text_Mining folder', 'Text_Mining folder', 'Text_Mining folder')
)

#########################################################################
# generate schedule doc
#########################################################################
# create workbook and add worksheet
commsched <- createWorkbook()
addWorksheet(commsched, 'Comm_Sched')

# create style for top row
Heading <- createStyle(
  textDecoration = 'bold', 
  fgFill = '#FFFFCC', 
  border = 'TopBottomLeftRight'
)

# format cells
cellStyle <- createStyle(
  border = 'TopBottomLeftRight'
)

writeData(commsched, 'Comm_Sched', fcq_comm_sched, headerStyle = Heading, borders = 'none')

addStyle(commsched, sheet = 'Comm_Sched', style = cellStyle,
         rows = 2:(nrow(fcq_comm_sched) + 1), cols = 1:ncol(fcq_comm_sched),
         gridExpand = TRUE)

# save/export the workbook
saveWorkbook(commsched, paste0(folder, 'Communications\\', term_cd, '\\', term_cd, '_Comm_Schedule.xlsx'), overwrite = TRUE)

#########################################################################
# generate communication docs in RMarkdown
#########################################################################

file.edit(paste0('C:\\Users\\', userid, '\\OneDrive - UCB-O365\\Documents\\oit-fcq\\code\\R\\create-sessions\\fcq_Comm_Docs.Rmd'))