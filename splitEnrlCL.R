##################################################################################
# split large stuenrll docs to fit Campus Labs import size limit
# typically used for BD and DN final administrations only
# L:\mgt\FCQ\R_Code\campus_labs\splitEnrlCL.R - Vince Darcangelo, 11/18/22
##################################################################################

# set up values
batch <- '23dn'
term <- '2251'
userid <- 'darcange'

folder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CampusLabs\\Imports\\', term, '\\Enrollment')

df <- read.csv(paste0(folder, '\\stuEnrl', term, '__batch', batch, '.csv'))
filename <- paste0(folder, '\\stuEnrl', term, '__batch', batch)

# number of items in each chunk
elements_per_chunk <- 15000

# list of rows for each chunk
l <- split(1:nrow(df), ceiling(seq_along(1:nrow(df))/elements_per_chunk))

# splits and saves csv files
for(i in 1:length(l)){
  write.csv(df[l[[i]],],
  file=paste0(filename, i, '.csv')
    , row.names = FALSE, na = '')
}
