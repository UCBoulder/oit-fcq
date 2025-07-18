#########################################################################
# Log of instructor info/class assgn since fall 2017
# L:\mgt\FCQ\R_Code\campus_labs\instCL_batch.R - Vince Darcangelo, 08/04/22
# Instructions
# Update # TERM UPDATE before each run - 
# Copy/paste to # PAST SEMESTERS after
# The purpose of this code is to maintain a running log of all evaluated instrs for reference and name/constituent id change purposes
#########################################################################

userid <- 'darcange'
term_cd <- 2241

# TERM UPDATE: UPDATE THIS BEFORE RUNNING!!!!!
file_names <- dir(paste0('C:\\Users\\', userid, '\\OneDrive - UCB-O365\\FCQ - AIM_ Measurement\\CampusLabs\\Imports\\', term_cd, '\\Instructor\\'))
setwd(paste0('C:\\Users\\', userid, '\\OneDrive - UCB-O365\\FCQ - AIM_ Measurement\\CampusLabs\\Imports\\', term_cd, '\\Instructor\\'))
instProd <- do.call(rbind,lapply(file_names,read.csv))

#########################################################################
# data manipulation step
instTerm <- substr(instProd$SectionIdentifier, 1, 4)
instCamp <- data.frame(substr(instProd$SectionIdentifier, 6, 15))
colnames(instCamp) <- 'instCamp'

# set campus data
instCamp2 <- instCamp %>%
  mutate(Campus = case_when(
    grepl(':BLDR', instCamp, ignore.case = TRUE) ~ 'BD',
    grepl(':BLD3', instCamp, ignore.case = TRUE) ~ 'B3',
    grepl(':CEPS', instCamp, ignore.case = TRUE) ~ 'CE',
    grepl("spg", instCamp, ignore.case = TRUE) ~ 'CS',
    grepl('DEN:MEDS', instCamp, ignore.case = TRUE) ~ 'MC',
    grepl('DEN:PHAR', instCamp, ignore.case = TRUE) ~ 'MC',
    TRUE ~ 'DN'))

###XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX###
# error check (should return 0)
instCamp0 <- instCamp2 %>%
  filter(Campus == 'DN' & !grepl('cuden', instCamp, ignore.case = TRUE))

while (TRUE) {
  if (nrow(instCamp0) == 0) {
    break
  } else {
    View(instCamp0)
    stop('Review and fix errors')
  }
}
###XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX###

# combine/rename all data
datasplit <- cbind(instProd, instTerm, instCamp2$Campus)
colnames(datasplit) <- c('PersonIdentifier', 'SectionIdentifier', 'FirstName', 'LastName', 'Email', 'Role', 'Term', 'Campus')

# import existing log
instLog <- read.csv(paste0('C:\\Users\\', userid, '\\OneDrive - UCB-O365\\FCQ - AIM_ Measurement\\CampusLabs\\Data_Files\\instLog.csv'))

# add new semester (datasplit) data to existing log
updatedLog <- rbind(instLog, datasplit)

# export updated log
write.csv(updatedLog, paste0('C:\\Users\\', userid, '\\OneDrive - UCB-O365\\FCQ - AIM_ Measurement\\CampusLabs\\Data_Files\\instLog.csv'), row.names = FALSE)

#########################################################################
# PAST SEMESTERS
file_names <- dir(paste0('C:\\Users\\', userid, '\\OneDrive - UCB-O365\\FCQ - AIM_ Measurement\\CampusLabs\\Imports\\', term_cd, '\\Instructor\\))
setwd(paste0('C:\\Users\\', userid, '\\OneDrive - UCB-O365\\FCQ - AIM_ Measurement\\CampusLabs\\Imports\\2231\\Instructor\\))
df2231 <- do.call(rbind,lapply(file_names,read.csv))

file_names <- dir("K:\\IR\\FCQ\\Prod\\2227\\Instructor\\")
setwd("K:\\IR\\FCQ\\Prod\\2227\\Instructor\\")
df2227 <- do.call(rbind,lapply(file_names,read.csv))

file_names <- dir("K:\\IR\\FCQ\\Prod\\2224\\Instructor\\")
setwd("K:\\IR\\FCQ\\Prod\\2224\\Instructor\\")
df2224 <- do.call(rbind,lapply(file_names,read.csv))

file_names <- dir("K:\\IR\\FCQ\\Prod\\2221\\Instructor\\")
setwd("K:\\IR\\FCQ\\Prod\\2221\\Instructor\\")
df2221 <- do.call(rbind,lapply(file_names,read.csv))

file_names <- dir("K:\\IR\\FCQ\\Prod\\2217\\Instructor\\")
setwd("K:\\IR\\FCQ\\Prod\\2217\\Instructor\\")
df2217 <- do.call(rbind,lapply(file_names,read.csv))

file_names <- dir("K:\\IR\\FCQ\\Prod\\2214\\Instructor\\")
setwd("K:\\IR\\FCQ\\Prod\\2214\\Instructor\\")
df2214 <- do.call(rbind,lapply(file_names,read.csv))

file_names <- dir("K:\\IR\\FCQ\\Prod\\2211\\Instructor\\")
setwd("K:\\IR\\FCQ\\Prod\\2211\\Instructor\\")
df2211 <- do.call(rbind,lapply(file_names,read.csv))

file_names <- dir("K:\\IR\\FCQ\\Prod\\2207\\Instructor\\")
setwd("K:\\IR\\FCQ\\Prod\\2207\\Instructor\\")
df2207 <- do.call(rbind,lapply(file_names,read.csv))

file_names <- dir("K:\\IR\\FCQ\\Prod\\2197\\Instructor\\")
setwd("K:\\IR\\FCQ\\Prod\\2197\\Instructor\\")
df2197 <- do.call(rbind,lapply(file_names,read.csv))

file_names <- dir("K:\\IR\\FCQ\\Prod\\2194\\Instructor\\")
setwd("K:\\IR\\FCQ\\Prod\\2194\\Instructor\\")
df2194 <- do.call(rbind,lapply(file_names,read.csv))

file_names <- dir("K:\\IR\\FCQ\\Prod\\2191\\Instructor\\")
setwd("K:\\IR\\FCQ\\Prod\\2191\\Instructor\\")
df2191 <- do.call(rbind,lapply(file_names,read.csv))

file_names <- dir("K:\\IR\\FCQ\\Prod\\2187\\Instructor\\")
setwd("K:\\IR\\FCQ\\Prod\\2187\\Instructor\\")
df2187 <- do.call(rbind,lapply(file_names,read.csv))

file_names <- dir("K:\\IR\\FCQ\\Prod\\2184\\Instructor\\")
setwd("K:\\IR\\FCQ\\Prod\\2184\\Instructor\\")
df2184 <- do.call(rbind,lapply(file_names,read.csv))

file_names <- dir("K:\\IR\\FCQ\\Prod\\2181\\Instructor\\")
setwd("K:\\IR\\FCQ\\Prod\\2181\\Instructor\\")
df2181 <- do.call(rbind,lapply(file_names,read.csv))

file_names <- dir("K:\\IR\\FCQ\\Prod\\2177\\Instructor\\")
setwd("K:\\IR\\FCQ\\Prod\\2177\\Instructor\\")
df2177 <- do.call(rbind,lapply(file_names,read.csv))

#instLog <- rbind(df2177, df2181, df2184, df2187, df2191, df2194, df2197, df2201, df2204, df2207, df2211, df2214, df2217, df2221)
