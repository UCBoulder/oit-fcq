##########################################################################
# compiles existing custom questions for reference (run as needed)
# created: Vince Darcangelo, 2/19/24
# most recent update: Vince Darcangelo 7/18/25
# \AIM Measurement - FCQ\R_Code\campus_labs\custQ_parse.R
##########################################################################

userid <- 'darcange'

# import cust q list
custqs <- read.csv(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\FCQ_CustomQs\\CustomQs.csv'))

text_a1 <- paste0('mutate(attr1 = case_when(')
text_a2 <- paste0('mutate(attr2 = case_when(')
text_a3 <- paste0('mutate(attr3 = case_when(')
text_a4 <- paste0('mutate(attr4 = case_when(')

text1 <- paste0('campus == \'', custqs_sbjct$campus, '\' & SBJCT_CD == \'', custqs_sbjct$sbjct_cd, '\' & CATALOG_NBR >= \'', custqs_sbjct$crsmin, '\' & CATALOG_NBR <= \'', custqs_sbjct$crsmax, '\' ~ ', '\'', custqs_sbjct$attr, '\'', ',')
text1

text_brk <- paste0('TRUE ~ \'\')) %>%')
text_end <- paste0('TRUE ~ \'\'))')

text2 <- paste0('campus == \'', custqs_sbjct_type$campus, '\' & SBJCT_CD == \'', custqs_sbjct_type$sbjct_cd, '\' & CATALOG_NBR >= \'', custqs_sbjct_type$crsmin, '\' & CATALOG_NBR <= \'', custqs_sbjct_type$crsmax, '\' & crseSec_comp_cd %in% c(', custqs_sbjct_type$compCdLst, ') ~ ', '\'', custqs_sbjct_type$attr, '\'', ',')
text2

text3 <- paste0('campus == \'', custqs_dept$campus, '\' & fcqdept == \'', custqs_dept$fcqdept, '\' ~ ', '\'', custqs_dept$attr, '\'', ',')
text3

text4 <- paste0('campus == \'', custqs_dept_type$campus, '\' & fcqdept == \'', custqs_dept_type$fcqdept, '\' & crseSec_comp_cd %in% c(', custqs_dept_type$compCdLst, ') ~ ', '\'', custqs_dept_type$attr, '\'', ',')
text4

thd1 <- data.frame(Text=text_a1, row.names=NULL)
thd2 <- data.frame(Text=text_a2, row.names=NULL)
thd3 <- data.frame(Text=text_a3, row.names=NULL)
thd4 <- data.frame(Text=text_a4, row.names=NULL)
tbr0 <- data.frame(Text=text_brk, row.names=NULL)
tbr9 <- data.frame(Text=text_end, row.names=NULL)
tdf1 <- data.frame(Text=text1, row.names=NULL)
tdf2 <- data.frame(Text=text2, row.names=NULL)
tdf3 <- data.frame(Text=text3, row.names=NULL)
tdf4 <- data.frame(Text=text4, row.names=NULL)

text_prse <- rbind(thd1, tdf1, tbr0, thd2, tdf2, tbr0, thd3, tdf3, tbr0, thd4, tdf4, tbr9)
write.csv(text_prse, paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - FCQ\\FCQ_CustomQs\\CustomQs.csv'), row.names = FALSE)
