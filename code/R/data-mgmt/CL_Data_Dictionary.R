#########################################################################
# Create data dictionary for CL files
# created: Vince Darcangelo 11/28/23
# most recent update: Vince Darcangelo 7/18/25
# \AIM Measurement - Documents\FCQ\R_Code\campus_labs\CL_Data_Dictionary.R 
#########################################################################

userid <- 'darcange'
folder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\')
dd_file <- paste0(folder, 'R_Code\\FCQ_Data_Dictionary.xlsx', overwrite = TRUE)

# clscu3 var info
clscu3_tbl <- head(clscu3)
# get var names
clscu3_key <- colnames(clscu3)
# get var type
clscu3_type <- sapply(clscu3, class)
# get unique values
clscu3_unq <- rapply(clscu3, function(x) length(unique(x)))
# create df
clscu3_dict <- as.data.frame(cbind(var = clscu3_key, type = clscu3_type, unique_no = clscu3_unq), row.names = FALSE)

# orgUnit
orgUnit_dict <- data.frame(
  var = c('OrgUnitIdentifier', 'Name', 'Acronym', 'ParentIdentifier', 'Type'),
  format = c('CUBLD:BLD3:CSCI', 'CU Computer Science Electives (CSCA)', 'CSCA', 'CUBLD:BLD3', 'Department'))

# term_row1
term1_dict <- data.frame(
  var = c('TermIdentifier', 'Name', 'BeginDate', 'EndDate', 'ParentIdentifier', 'Type'),
  format = c('2237', 'Fall 2023', '2023-08-01T17:00:00-07:00', '2023-12-31T17:00:00-07:00', '', 'Semester'))

# term
term_dict <- data.frame(
  var = c('TermIdentifier', 'Name', 'BeginDate', 'EndDate', 'ParentIdentifier', 'Type'),
  format = c('2237:CUBLD:BLDR', 'Fall 2023 CU Boulder main campus semester', '2023-08-01T17:00:00-07:00', '2023-12-31T17:00:00-07:00', '2237', 'Intersession'))

# instAcct_import
instAcct_tbl <- as.list(head(instAcct_import, n = 1))
instAcct_key <- colnames(instAcct_import)
instAcct_dict <- as.data.frame(cbind(var = instAcct_key, format = instAcct_tbl), row.names = FALSE)

# stuAcct_import
stuAcct_tbl <- as.list(head(stuAcct_import, n = 1))
stuAcct_key <- colnames(stuAcct_import)
stuAcct_dict <- as.data.frame(cbind(var = stuAcct_key, format = stuAcct_tbl), row.names = FALSE)

# crsecsv
crsecsv_tbl <- as.list(head(crsecsv, n = 1))
crsecsv_key <- colnames(crsecsv)
crsecsv_dict <- as.data.frame(cbind(var = crsecsv_key, format = crsecsv_tbl), row.names = FALSE)

# sectcsv
sectcsv_tbl <- as.list(head(sectcsv, n = 1))
sectcsv_key <- colnames(sectcsv)
sectcsv_dict <- as.data.frame(cbind(var = sectcsv_key, format = sectcsv_tbl), row.names = FALSE)

# instcsv
instcsv_tbl <- as.list(head(instcsv, n = 1))
instcsv_key <- colnames(instcsv)
instcsv_dict <- as.data.frame(cbind(var = instcsv_key, format = instcsv_tbl), row.names = FALSE)

# stuenrl_cmbd6
stuenrl_tbl <- as.list(head(stuenrl_cmbd6, n = 1))
stuenrl_key <- colnames(stuenrl_cmbd6)
stuenrl_dict <- as.data.frame(cbind(var = stuenrl_key, format = stuenrl_tbl), row.names = FALSE)

# sess_attr
sectattr_tbl <- as.list(head(sess_attr, n = 1))
sectattr_key <- colnames(sess_attr)
sectattr_dict <- as.data.frame(cbind(var = sectattr_key, format = sectattr_tbl), row.names = FALSE)

#########################################################################
# Combine and export to xlsx file
#########################################################################

# output to xlsx file
cldata_dict <- createWorkbook()
addWorksheet(cldata_dict, 'clscu3')
addWorksheet(cldata_dict, 'orgUnit')
addWorksheet(cldata_dict, 'term1')
addWorksheet(cldata_dict, 'term')
addWorksheet(cldata_dict, 'instAcct')
addWorksheet(cldata_dict, 'stuAcct')
addWorksheet(cldata_dict, 'crsecsv')
addWorksheet(cldata_dict, 'sectcsv')
addWorksheet(cldata_dict, 'instcsv')
addWorksheet(cldata_dict, 'stuenrl')
addWorksheet(cldata_dict, 'sectattr')

# freeze panes
freezePane(cldata_dict, 1, firstActiveRow = 2)
freezePane(cldata_dict, 2, firstActiveRow = 2)
freezePane(cldata_dict, 3, firstActiveRow = 2)
freezePane(cldata_dict, 4, firstActiveRow = 2)
freezePane(cldata_dict, 5, firstActiveRow = 2)
freezePane(cldata_dict, 6, firstActiveRow = 2)
freezePane(cldata_dict, 7, firstActiveRow = 2)
freezePane(cldata_dict, 8, firstActiveRow = 2)
freezePane(cldata_dict, 9, firstActiveRow = 2)
freezePane(cldata_dict, 10, firstActiveRow = 2)
freezePane(cldata_dict, 11, firstActiveRow = 2)

# create tables
writeDataTable(cldata_dict, 1, clscu3_dict)
writeDataTable(cldata_dict, 2, orgUnit_dict)
writeDataTable(cldata_dict, 3, term1_dict)
writeDataTable(cldata_dict, 4, term_dict)
writeDataTable(cldata_dict, 5, instAcct_dict)
writeDataTable(cldata_dict, 6, stuAcct_dict)
writeDataTable(cldata_dict, 7, crsecsv_dict)
writeDataTable(cldata_dict, 8, sectcsv_dict)
writeDataTable(cldata_dict, 9, instcsv_dict)
writeDataTable(cldata_dict, 10, stuenrl_dict)
writeDataTable(cldata_dict, 11, sectattr_dict)

# save
saveWorkbook(data_dict, file = dd_file)
