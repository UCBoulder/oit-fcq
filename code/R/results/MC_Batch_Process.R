#######################################################################
# Anschutz: process and sort batch report PDFs from Campus Labs
# created: Vince Darcangelo 08/31/22
# most recent update: Vince Darcangelo 1/23/25
# \AIM Measurement - FCQ\R_Code\mc_results\MC_Batch_Process.R
#######################################################################

# PREP BEFORE RUNNING CODE:
# 1. request batch reports from Campus Labs when the results come out
# 2. Campus Labs will email us when they arrive (usually 2-3 days)
# 3. create a term folder in \Batch_Reports folder
# 4. access the .zip file from transfer.campuslabs.com
# 5. file will be in the folder named for most recent term (e.g., 2224)
# 6. download the .zip file to the newly created term folder
# 7. rename with campus/term format (e.g., MC2224)
# 8. extract files to campus/term folder

# UPDATE term VAR EACH SEMESTER:
term <- 2247
campus <- 'AMC'
campterm <- paste0('MC', term)
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
cfolder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\Batch_Reports\\', term, '\\AMC')

if (!dir.exists(cfolder)) {
  dir.create(cfolder)
  cat(paste('Directory', cfolder, 'created.\n'))
} else {
  cat(paste('Directory', cfolder, 'already exists.\n'))
}

# set destination file for zip files
dfolder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\Batch_Reports\\AMC')

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
mc_match <- read.csv(paste0('C:\\Users\\', userid, '\\UCB-o365\\AIM Measurement - FCQ\\CampusLabs\\Response_Exports\\', term, '\\MC_Inst_Batch.csv'))

# create unique rows for mc_match
mc_match2 <- mc_match %>%
  select(Instructor_External_ID, Instructor, ACAD_ORG_CD) %>%
  unique()

# combine pdf file data with inst/dept data for sorting
my_comb <- left_join(x = my_files, y = mc_match, by = 'Instructor_External_ID')

# remove NA values (files/folders created for classes with 0 responses)
my_comb2 <- my_comb %>%
  filter(!(is.na(Instructor)))

# setwd() to target folder
setwd(cfolder)

#########################################################################
# clean up and map
my_comb3 <- my_comb2 %>%
  mutate(ACAD_ORG_CD = gsub('D-', 'MC-', ACAD_ORG_CD))

# create mapping doc
mc_map <- my_comb3 %>%
  mutate(dest = paste0(getwd(), '/', term, '-', ACAD_ORG_CD, '/', match))

# create dept folders
for (i in 1:length(mc_map$dest)){
  dir.create(paste0(getwd(), '/', term, '-', mc_map$ACAD_ORG_CD[i]))
}

# create inst folders
for (i in 1:length(mc_map$dest)){
  dir.create(mc_map$dest[i])
}

# move files
file.copy(from = mc_map$srcnm, to = file.path(mc_map$dest, basename(mc_map$srcnm)))

#########################################################################
# identify inst who taught in multiple depts
#########################################################################

mc_dups <- mc_map %>%
  mutate(dup = paste0(match, ACAD_ORG_CD)) %>%
  select(-c(suf, srcnm)) %>%
  group_by(dup) %>%
  unique() %>%
  ungroup() %>%
  group_by(Instructor_External_ID) %>%
  filter(n()>1)

write.csv(mc_dups, 'mc_dups_file.csv')

mc_dups2 <- mc_dups %>%
  mutate(from = paste0(stem, '\\', match)) %>%
  select(from)

mc_dups3 <- mc_dups2 %>%
  left_join(select(mc_dups, -dest), 'Instructor_External_ID') %>%
  mutate(dest = paste0(cfolder, '\\', ACAD_ORG_CD, '\\', match))

mc_dups4 <- mc_dups3 %>%
  select(-c(Instructor_External_ID, stem, match, dup, extract, Instructor, ACAD_ORG_CD))

mc_dups4b <- mc_map %>%
  select(srcnm, dest, suf)

mc_dups5 <- left_join(mc_dups4, mc_dups4b, 'dest')

mc_dups5 <- mc_dups5 %>%
  unique() %>%
  mutate(dfrom = paste0(from, '/', suf)) %>%
  mutate(dfile = paste0(dest, '/', suf))

file.copy(from = mc_dups5$dfrom, to = mc_dups5$dfile, overwrite = TRUE)

file.copy(from = mc_map$srcnm, to = file.path(mc_map$dest, basename(mc_map$srcnm)))

#########################################################################
# create zip files
setwd(cfolder)

files2zip <- dir(cfolder)

zlist <- as.list(dir(cfolder))

zlist <- dir(cfolder, full.names = TRUE)

zlist2 <- paste0(zlist, '.zip')

for (i in 1:length(zlist2)) {
zip(zlist2[i], files = files2zip[i])
}

folder_update <- unique(mc_map$ACAD_ORG_CD)
folder_update <- enframe(folder_update)
folder_update <- folder_update %>% select(value) %>% arrange(value)
write.csv(folder_update, 'mc_folders2update.csv')
