##########################################################################
# creates a .csv file to import new departments to Campus Labs
# created: Vince Darcangelo 12/19/22
# most recent update: Vince Darcangelo 7/18/25
# \OneDrive - UCB-O365\Documents\oit-fcq\code\R\account-mgmt\CL_Dept_Create.R
##########################################################################

# set date and term
entrydt <- Sys.Date()
entrydt <- format(entrydt, format = '%Y%m%d')

term_cd <- 2257
userid <- 'darcange'
folder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\')

# set values of new dept (format for non-dept (e.g., division, school) below)
df <- data.frame(

# format: CUBLD:BLDR:ENES, CUBLD:CEPS:BBAC, CUDEN:ENGR:D-IWKS, CUDEN:MEDS:D-BCMG
OrgUnitIdentifier = c('CUBLD:BLDR:PBHL', 'CUDEN:CLAS:CCST'),

# format: CU Boulder deptnm (ENES), CU Continuing Ed deptnm (BBAC), CU Denver deptnm (IWKS), CU Denver deptnm (MEDS:D-BCMG)
Name = c('CU Boulder Public Health (PBHL)', 'CU Denver Climate Change Studies (CCST)'),

# format: ENES, CEPS:BBAC, D-IWKS, D-BCMG
Acronym = c('PBHL', 'D-CCST'),

# format: CUBLD:BLDR, CEPS:CEPS, CUDEN:ENGR, CUDEN:CLAS, CUDEN:MEDS
ParentIdentifier = c('CUBLD:BLDR', 'CUDEN:CLAS'),

# options: Division (campus), School (college), Department
Type = c('Department', 'Department')
)

write.csv(df, paste0(folder, 'CampusLabs\\Imports\\', term_cd, '\\OrgUnit\\CLOrgUnits_', entrydt, '.csv'), row.names = FALSE)

#########################################################################
# hierarchy in campus labs for reference

# Institution (University of Colorado) 
#   > Academic Affairs (level 1) 
#     > Division (level 2) 
#       > School (level 3)
#         > Department (level 4)

# formatting
# CU,	University of Colorado,	CU,	, Institution
# AA,	Academic Affairs,	AA,	CU,	Division
# CUBLD,	CU Boulder (CUBLD),	CUBLD,	AA,	Division
# CUDEN,	CU Denver (CUDEN),	CUDEN,	AA,	Division
# CUSPG,	CU Colorado Springs (CUSPG),	CUSPG,	AA,	Division
# CUBLD:BLDR,	CU Boulder main campus (BLDR),	CUBLD:BLDR,	CUBLD,	Division
# CUBLD:CEPS,	CU Continuing Education (CEPS),	CUBLD:CEPS,	CUBLD,	Division
# CUDEN:MEDS,	CU Denver Anschutz Graduate Studies (MEDS),	CUDEN:MEDS,	CUDEN,	School
