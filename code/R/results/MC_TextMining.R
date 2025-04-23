#########################################################################
# Text mining AMC FCQ comments
# created: Vince Darcangelo 2/10/22
# most recent update: Vince Darcangelo 2/20/25
# \AIM Measurement - FCQ\R_Code\mc_results\MC_TextMining.R
#########################################################################

# set up new term
term <- '2247'
userid <- 'darcange'

# set up folder for new term
dir_path <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\Text_Mining\\', term)

# check for directory, and create if not
if (!dir.exists(dir_path)) {
  dir.create(dir_path)
  cat(paste('Directory', dir_path, 'created.\n'))
} else {
  cat(paste('Directory', dir_path, 'already exists.\n'))
}

# setwd
setwd(dir_path)

# load packages
library('openxlsx')
library('tidyr')
library('dplyr')
library('ggplot2')
library('tidyverse')
library('stringr')
library('qdap')
library('tm')
library('data.table')
library('SnowballC')
library('ggthemes')

#########################################################################

# upload response export file
mctxt <- read.csv(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CampusLabs\\Response_Exports\\', term, '\\MC_response_export.csv'))
cols <- c(1:2, 4:7, 10:11, 36:37)
mctxt <- mctxt[,cols]

# rename columns
colnames(mctxt) <- c('CE_Internal_ID', 'Student_Identifier', 'Course_Section_External_ID', 'Course_Section_Label', 'Department', 'Administration_Name', 'Instructor', 'Instructor_External_ID', 'Comments1', 'Comments2')

# remove course items, separate comment columns (1 = left, 2 = right), rename
mctxt2 <- subset(mctxt, Instructor_External_ID != 'Course Section Results')
mctxtleft <- subset(mctxt2, select = -Comments2)
mctxtleft <- subset(mctxtleft, Comments1 != '')
mctxtleft <- rename(mctxtleft, Comments = Comments1)
mctxtright <- subset(mctxt2, select = -Comments1)
mctxtright <- subset(mctxtright, Comments2 != '')
mctxtright <- rename(mctxtright, Comments = Comments2)

# combine dntxtleft and dntxtright
mctxt3 = rbind(mctxtleft, mctxtright)

# create Key based on CE_Internal_ID and Course_Section_External_ID columns
mctxt3 <- mctxt3 %>%
  mutate(Key = paste(CE_Internal_ID, Course_Section_External_ID, sep = '_'))

# replace symbols and oddities
mctxt3$Comments <- gsub('1\\|', '', mctxt3$Comments)
mctxt3$Comments <- gsub('\\â\\€\\™', "'", mctxt3$Comments)
mctxt3$Comments <- gsub('\\â\\€\\œ', "'", mctxt3$Comments)
mctxt3$Comments <- gsub('\\â\\€\\.', "'", mctxt3$Comments)
mctxt3$Comments <- gsub('\\â\\€¦', '...', mctxt3$Comments)
mctxt3$Comments <- gsub('\\â\\€\\”', '-', mctxt3$Comments)
mctxt3$Comments <- gsub('\\â\\€\\“', '-', mctxt3$Comments)
mctxt3$Comments <- gsub('\\â\\€\\˜', "'", mctxt3$Comments)
mctxt3$Comments <- gsub('\\â\\€\\¢', '-', mctxt3$Comments)
mctxt3$Comments <- gsub('\\â\\€\\º', "'", mctxt3$Comments)
mctxt3$Comments <- gsub('\\â\\€\\‹', '', mctxt3$Comments)
mctxt3$Comments <- gsub('\\â\\€\\š', "'", mctxt3$Comments)

# remove \n (line breaks)
mctxt3$Comments <- gsub('\n', '', mctxt3$Comments)

# export raw file with all comments
write.csv(mctxt3, paste0('MC_Raw_', term, '.csv'), row.names = FALSE)

########################################################################

# load word stems and keyword corpora
words <- c('\\babus', 'accommodat', '\\bage', '\\bass ', 'assault', 'attack', 'belittl', '\\bberat', 'bitch', '\\bull', 'of color ', 'creed', 'dead ', '\\bdie', 'degrade', 'demean', 'disable', 'disability', 'discriminat', 'flirt', 'fuck', 'gender expression', 'gender identity', 'harass', 'homicid', 'homophob', 'hostil', 'humiliat', '\\bkill ', '\\bkilling ', 'kms', 'murder', 'national origin', 'political affiliation', 'political philosophy', 'pregnan', 'prejudic', '\\brace', 'racial', 'racist', 'religion', 'retaliat', 'revenge', 'ridicule', '\\bsex', 'sexual orientation', '\\bshit', 'suicid', 'threat', 'trans ', 'transgender', 'veteran status')

tags <- c('abuse', 'accommodations', 'age', 'ass', 'assault', 'attack', 'belittle', 'berate', 'bitch', 'bully', 'of color', 'creed', 'dead', 'die', 'degrade', 'demean', 'disable', 'disability', 'discriminate', 'flirt', 'fuck', 'gender expression', 'gender identity', 'harass', 'homicide', 'homophobia', 'hostile', 'humiliate', 'kill', 'kill', 'suicide', 'murder', 'national origin', 'political affiliation', 'political philosophy', 'pregnant', 'prejudice', 'race', 'racial', 'racist', 'religion', 'retaliation', 'revenge', 'ridicule', 'sex', 'sexual orientation', 'shit', 'suicide', 'threat', 'trans', 'transgender', 'veteran status')

keywords <- paste(words, collapse = '|')

# extract the list of matching words
x <- sapply(words, function(x) grepl(tolower(x), tolower(mctxt3$Comments)))

# paste the matching words together
mctxt3$match <- apply(x, 1, function(i) paste0(names(i)[i], collapse = ','))

# remove unflagged comments
mcFlagged <- subset(mctxt3, match != '')

# create character vector replacing the stems (words) with keywords (tags)
stem_fix <- mgsub(words, tags, mcFlagged$match)

# append stem_fix to dataframe (this attaches a new column with proper keywords)
mcFlagged$Keywords<- stem_fix

# remove match column (stems)
mcFlagged = subset(mcFlagged, select = -match)

# export to csv file for review
write.csv(mcFlagged, 'mcFlagged.csv', row.names = FALSE)

# export raw file with all comments
write.csv(mctxt3, paste0('mcAllText_', term, '.csv'), row.names = FALSE)
