##########################################################################
# split large stuenrll docs to fit Campus Labs import size limit 
# use for BD and DN fall/spring final admins
# created: Vince Darcangelo, 11/18/22
# most recent update: Vince Darcangelo 7/18/25
# \AIM Measurement - FCQ\R_Code\campus_labs\splitEnrlCL.R
##########################################################################

# set up values
batch <- '23dn'
term_cd <- '2251'
userid <- 'darcange'

folder <- paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\CampusLabs\\Imports\\', term_cd, '\\Enrollment')

df <- read.csv(paste0(folder, '\\stuEnrl', term_cd, '__batch', batch, '.csv'))
filename <- paste0(folder, '\\stuEnrl', term_cd, '__batch', batch)

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
