#######################################################################
# Boulder: process and sort batch report PDFs from Campus Labs
# created: Vince Darcangelo 08/31/22
# most recent update: Vince Darcangelo 1/23/25
# \AIM Measurement - FCQ\R_Code\bd_results\BD_Batch_Process.R
#######################################################################

# PREP BEFORE RUNNING CODE:
# 1. request batch reports from Campus Labs when the results come out
# 2. Campus Labs will email us when they arrive (usually 2-3 days)
# 3. create a term folder in \Batch_Reports folder
# 4. access the .zip file from transfer.campuslabs.com
# 5. file will be in the folder named for most recent term (e.g., 2224)
# 6. download the .zip file to the newly created term folder
# 7. rename with campus/term format (e.g., BD2224)
# 8. extract files to campus/term folder

# UPDATE term VAR EACH SEMESTER:
term <- 2247
campus <- 'Boulder'
campterm <- paste0('BD', term)
userid <- 'darcange'

# check for term directory, and create if not
tfolder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\Batch_Reports\\', term)

if (!dir.exists(tfolder)) {
  dir.create(tfolder)
  cat(paste('Directory', tfolder, 'created.\n'))
} else {
  cat(paste('Directory', tfolder, 'already exists.\n'))
}

setwd(tfolder)

# check for campus directory, and create if not
cfolder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\Batch_Reports\\', term, '\\Boulder')

if (!dir.exists(cfolder)) {
  dir.create(cfolder)
  cat(paste('Directory', cfolder, 'created.\n'))
} else {
  cat(paste('Directory', cfolder, 'already exists.\n'))
}

# set destination file for zip files
dfolder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\Batch_Reports\\Boulder')

# load libraries
library('tibble')
library('tidyr')

# create list of zipped files
unzip_list <- unzip(paste0(tfolder, '\\', campterm, '.zip'), list = TRUE, exdir = '.')

# format unzip_list
unzip_list <- enframe(str_remove(unzip_list$Name, '^([^.]+.){2}'), value = 'Name')
unzip_list <- enframe(str_remove(unzip_list$Name, '@cu.edu/Quantitative.pdf'), value = 'Name')
unzip_list <- enframe(str_remove(unzip_list$Name, '@cu.edu/Qualitative.pdf'), value = 'Name')
unzip_list <- unzip_list %>% select(-name)

# get list of file names
my_files <- list.files(paste0(tfolder, '\\', campterm), full.names = TRUE, recursive = TRUE)

# get list of folder names
my_folders <- list.files(paste0(tfolder, '\\', campterm))

# convert lists to tibbles and duplicate value column
my_files0 <- enframe(my_files)
my_files <- my_files0 %>% select(value) %>% mutate(srcnm = value)

my_folders <- enframe(my_folders)
my_folders <- my_folders %>% select(value)

# modify my_files to match
my_files <- separate(my_files, value, into = c('stem', 'match', 'suf'), sep = '/')

# pull constituent ID from CL file name (note: also removes '@cu.edu')
my_files$extract <- gsub('(?:.*\\.){1}([^@]+)@.*', '\\1', my_files$match)

# create matching column that restores '@cu.edu'
my_files <- my_files %>%
  mutate(Instructor_External_ID = paste0(extract, '@cu.edu'))

# import batch matching file from results processing code
bd_match <- read.csv(paste0('C:\\Users\\', userid, '\\UCB-o365\\AIM Measurement - FCQ\\CampusLabs\\Response_Exports\\', term, '\\BD_Inst_Batch.csv'))

# create unique rows for bd_match
bd_match2 <- bd_match %>%
  select(Instructor_External_ID, Instructor, fcqdept) %>%
  unique()

##############################################################################################################################################################
# Review - should be bd_match2?????
################################################################################
# combine pdf file data with inst/dept data for sorting
my_comb <- left_join(x = my_files, y = bd_match, by = 'Instructor_External_ID')

# remove NA values (files/folders created for classes with 0 responses)
my_comb2 <- my_comb %>%
  filter(!(is.na(Instructor)))

# tbd
# bring in instrNm to rename folders

# setwd() to target folder
setwd(cfolder)

#########################################################################
# sep B3 and CEPS from main campus
my_comb3 <- my_comb2 %>%
  mutate(ACAD_ORG_CD = case_when(
    fcqdept == 'ECEA' ~ paste0('B3-', fcqdept),
    fcqdept == 'EDUA' ~ paste0('B3-', fcqdept),
    TRUE ~ ACAD_ORG_CD
  )) %>%
  mutate(ACAD_ORG_CD = case_when(
    fcqdept %in% c('BBAC', 'CC', 'CONT', 'IEC', 'ORGL', 'TRCT') ~ paste0('CE-', fcqdept),
    TRUE ~ ACAD_ORG_CD
  )) %>%
  mutate(ACAD_ORG_CD = gsub('B-', 'BD-', ACAD_ORG_CD))

# create mapping doc
bd_map <- my_comb3 %>%
  mutate(dest = paste0(getwd(), '/', term, '-', ACAD_ORG_CD, '/', match))

# create dept folders
for (i in 1:length(bd_map$dest)){
  dir.create(paste0(getwd(), '/', term, '-', bd_map$ACAD_ORG_CD[i]))
}

# create inst folders
for (i in 1:length(bd_map$dest)){
  dir.create(bd_map$dest[i])
}

# move files
file.copy(from = bd_map$srcnm, to = file.path(bd_map$dest, basename(bd_map$srcnm)))

#########################################################################
# identify inst who taught in multiple depts
#########################################################################

bd_dups <- bd_map %>%
  mutate(dup = paste0(match,fcqdept)) %>%
  select(-c(suf, srcnm, SBJCT_CD, ACAD_ORG_CD)) %>%
  group_by(dup) %>%
  unique() %>%
  ungroup() %>%
  group_by(Instructor_External_ID) %>%
  filter(n()>1)

write.csv(bd_dups, 'bd_dups_file.csv')

bd_dups2 <- bd_dups %>%
  mutate(from = paste0(stem, '\\', match)) %>%
  select(from)

bd_dups3 <- bd_dups2 %>%
  left_join(select(bd_dups, -dest), 'Instructor_External_ID') %>%
  mutate(dest = paste0(cfolder, '\\', fcqdept, '\\', match))

bd_dups4 <- bd_dups3 %>%
  select(-c(Instructor_External_ID, stem, match, dup, extract, Instructor, fcqdept))

bd_dups4b <- bd_map %>%
  select(srcnm, dest, suf)

bd_dups5 <- left_join(bd_dups4, bd_dups4b, 'dest')

bd_dups5 <- bd_dups5 %>%
  unique() %>%
  mutate(dfrom = paste0(from, '/', suf)) %>%
  mutate(dfile = paste0(dest, '/', suf))

file.copy(bd_dups5$dfrom, bd_dups5$dfile, overwrite = TRUE)

#########################################################################
# create zip files
#########################################################################
setwd(cfolder)

files2zip <- dir(cfolder)

#zlist <- as.list(cfolder)
zlist <- dir(cfolder, full.names = TRUE)

zlist2 <- enframe(zlist)
zlist3 <- zlist2 %>%
  select(value) %>%
  mutate(match = substr(value, nchar(value)-6, nchar(value))) %>%
  mutate(match = gsub('1-', '', match)) %>%
  mutate(match = gsub('4-', '', match)) %>%
  mutate(match = gsub('7-', '', match)) %>%
  mutate(match = gsub('^-', '', match)) %>%
  mutate(zip = value)

#ylist <- as.list(dfolder)
ylist <- dir(dfolder, full.names = TRUE)

# create ylist2 and zlist2, each with a column extracting the last 7 chars from the primary column
ylist2 <- enframe(ylist)
ylist3 <- ylist2 %>%
  select(value) %>%
  mutate(match = substr(value, nchar(value)-6, nchar(value))) %>%
  mutate(match = gsub('r/', '', match)) %>%
  mutate(match = gsub('/', '', match))

yz_comb <- zlist3 %>%
  select(match, zip) %>%
  left_join(ylist3) %>%
  mutate(value = case_when(
    match == 'CE-BBAC' ~ paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\Batch_Reports\\CEPS\\CE-BBAC'),
    match == 'CE-CC' ~ paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\Batch_Reports\\CEPS\\CE-CC'),
    match == 'CE-CONT' ~ paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\Batch_Reports\\CEPS\\CE-CONT'),
    match == 'CE-IEC' ~ paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\Batch_Reports\\CEPS\\CE-IEC'),
    match == 'CE-ORGL' ~ paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\Batch_Reports\\CEPS\\CE-ORGL'),
    match == 'CE-TRCT' ~ paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\Batch_Reports\\CEPS\\CE-TRCT'),
    TRUE ~ value
  ))

yzlist <- as.list(yz_comb$value)
files2zip2 <- grep('-', files2zip, value = TRUE)

for (i in seq_along(files2zip2)) {
  file_name <- files2zip2[i]
  folder_name <- yzlist[i]

zip_file_path <- file.path(cfolder, paste0(file_name, '.zip'))

zip(zipfile = zip_file_path, files = file.path(cfolder, file_name))

target_folder <- file.path(folder_name)
  
# Move the zip file to the target folder
file.copy(zip_file_path, file.path(target_folder, paste0(file_name, '.zip')))
}

# print list of folders to update
folder_update <- unique(bd_map$ACAD_ORG_CD)
folder_update <- enframe(folder_update)
folder_update <- folder_update %>% select(value) %>% arrange(value)
write.csv(folder_update, 'bd_folders2update.csv')

# end of functions
