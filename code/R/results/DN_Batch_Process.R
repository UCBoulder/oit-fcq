#######################################################################
# Denver: process and sort batch report PDFs from Campus Labs
# created: Vince Darcangelo 8/24/22
# most recent update: Vince Darcangelo 1/23/25
# \AIM Measurement - FCQ\R_Code\dn_results\DN_Batch_Process.R
#######################################################################

# PREP BEFORE RUNNING CODE:
# 1. request batch reports from Campus Labs when the results come out
# 2. Campus Labs will email us when they arrive (usually 2-3 days)
# 3. create a term folder in \Batch_Reports folder
# 4. access the .zip file from transfer.campuslabs.com
# 5. file will be in the folder named for most recent term (e.g., 2224)
# 6. download the .zip file to the newly created term folder
# 7. rename with campus/term format (e.g., DN2224)
# 8. extract files to campus/term folder

# UPDATE term VAR EACH SEMESTER:
term <- 2247
campus <- 'Denver'
campterm <- paste0('DN', term)
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
cfolder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\Batch_Reports\\', term, '\\Denver')

if (!dir.exists(cfolder)) {
  dir.create(cfolder)
  cat(paste('Directory', cfolder, 'created.\n'))
} else {
  cat(paste('Directory', cfolder, 'already exists.\n'))
}

# set destination file for zip files
dfolder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\Batch_Reports\\Denver')

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
dn_match <- read.csv(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CampusLabs\\Response_Exports\\', term, '\\DN_Inst_Batch.csv'))

# create unique rows for dn_match
dn_match2 <- dn_match %>%
  select(Instructor_External_ID, Instructor, fcqdept, ACAD_ORG_CD) %>%
  unique()

# combine pdf file data with inst/dept data for sorting
my_comb <- left_join(x = my_files, y = dn_match2, by = 'Instructor_External_ID')

# remove NA values (files/folders created for classes with 0 responses)
my_comb2 <- my_comb %>%
  filter(!(is.na(Instructor)))

# tbd
# bring in instrNm to rename folders

# setwd() to target folder
setwd(cfolder)

#########################################################################
# sep NCOR-CLAS from D-CLAS
my_comb3 <- my_comb2 %>%
  mutate(ACAD_ORG_CD = case_when(
    fcqdept == 'NOCR' ~ 'D-NCLL',
    TRUE ~ ACAD_ORG_CD)) %>%
  mutate(ACAD_ORG_CD = gsub('D-', 'DN-', ACAD_ORG_CD))
#  select(-fcqdept)

# create mapping doc
dn_map <- my_comb3 %>%
  mutate(dest = paste0(getwd(), '/', term, '-', ACAD_ORG_CD, '/', match))

# create dept folders
for (i in 1:length(dn_map$dest)){
  dir.create(paste0(getwd(), '/', term, '-', dn_map$ACAD_ORG_CD[i]))
}

# create inst folders
for (i in 1:length(dn_map$dest)){
  dir.create(dn_map$dest[i])
}

# move files
file.copy(from = dn_map$srcnm, to = file.path(dn_map$dest, basename(dn_map$srcnm)))

#########################################################################
# identify inst who taught in multiple depts
#########################################################################

dn_dups <- dn_map %>%
  mutate(dup = paste0(match, ACAD_ORG_CD)) %>%
  select(-c(suf, srcnm)) %>%
  group_by(dup) %>%
  unique() %>%
  ungroup() %>%
  group_by(Instructor_External_ID) %>%
  filter(n()>1)

write.csv(dn_dups, 'dn_dups_file.csv')

dn_dups2 <- dn_dups %>%
  mutate(from = paste0(stem, '\\', match)) %>%
  select(from)

dn_dups3 <- dn_dups2 %>%
  left_join(select(dn_dups, -dest), 'Instructor_External_ID') %>%
  mutate(dest = paste0(cfolder, '\\', ACAD_ORG_CD, '\\', match))

dn_dups4 <- dn_dups3 %>%
  select(-c(Instructor_External_ID, stem, match, dup, extract, Instructor, ACAD_ORG_CD))

dn_dups4b <- dn_map %>%
  select(srcnm, dest, suf)

dn_dups5 <- left_join(dn_dups4, dn_dups4b, 'dest')

dn_dups5 <- dn_dups5 %>%
  unique() %>%
  mutate(dfrom = paste0(from, '/', suf)) %>%
  mutate(dfile = paste0(dest, '/', suf))

file.copy(from = dn_dups5$dfrom, to = dn_dups5$dfile, overwrite = TRUE)

file.copy(from = dn_map$srcnm, to = file.path(dn_map$dest, basename(dn_map$srcnm)))

#########################################################################
# create zip files
#########################################################################
setwd(cfolder)

files2zip <- dir(cfolder)

zlist <- as.list(dir(cfolder))

zlist <- dir(cfolder, full.names = TRUE)

zlist2 <- paste0(zlist, '.zip')

for (i in 1:length(zlist2)) {
zip(zlist2[i], files = files2zip[i])
}

folder_update <- unique(dn_map$ACAD_ORG_CD)
folder_update <- enframe(folder_update)
folder_update <- folder_update %>% select(value) %>% arrange(value)
write.csv(folder_update, 'dn_folders2update.csv')

#########################################################################
# end of script
#########################################################################
