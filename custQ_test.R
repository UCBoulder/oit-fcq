#########################################################################
#
userid <- 'darcange'
term_cd <- 2241

# import cust q list
custqs <- read.csv(paste0('C:\\Users\\', userid, '\\OneDrive - UCB-O365\\FCQ - AIM_ Measurement\\FCQ_CustomQs\\CustomQs.csv'))

# import cumulative list from K:\ (only run after created)
semqs <- read.csv(paste0('C:\\User\\', userid, '\\OneDrive - UCB-O365\\FCQ - AIM_ Measurement\\CampusLabs\\Imports\\', term_cd, '\\SectionAttribute\\secAttr', term_cd, '.csv'))

# select cols from session to match AND to create Identifier
session3 <- clscu %>%
  ungroup() %>%
  select(campus, deptOrgID, fcqdept, TERM_CD, SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, INSTRCTR_ROLE_CD, crseSec_comp_cd) %>%
  mutate(Identifier = paste(TERM_CD, deptOrgID, SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, crseSec_comp_cd, sep = "_")) %>%
  mutate(CATALOG_NBR = as.numeric(CATALOG_NBR))

##### assign attr
# sbjct_cd based ONLY
custqs_sbjct <- custqs %>%
  filter(fcqdept == '' & compCdLst == '')

# sbjct_cd plus crse type
custqs_sbjct_type <- custqs %>%
  filter(fcqdept == '' & compCdLst != '')

# fcqdept based ONLY
custqs_dept <- custqs %>%
  filter(fcqdept != '' & compCdLst == '')

# fcqdept plus crse type
custqs_dept_type <- custqs %>%
  filter(fcqdept != '' & compCdLst != '')


# testgrp
testgrp <- clscu %>%
  filter(campus == 'DN' & SBJCT_CD == 'ELEC') %>%
  mutate(attr1 = case_when(
    campus == custqs_sbjct$campus & SBJCT_CD == custqs_sbjct$sbjct_cd ~ custqs_sbjct$attr,
    TRUE ~ ''))

# join test 10/25: sbjct_cd plus compCdLst
jointst1 <-left_join(testgrp, custqs_sbjct_type, by=c("campus","SBJCT_CD" = "sbjct_cd", "crseSec_comp_cd" = "compCdLst")) %>%
  rowwise() %>%
  mutate(attr1 = ifelse(CATALOG_NBR >= crsmin & CATALOG_NBR <= crsmax, attr, '')) %>%
  select(-fcqdept.y, -crsmin, -crsmax, -attr) %>%
  rename(fcqdept = fcqdept.x) %>%
  distinct() %>%
  mutate(key = paste(Identifier, INSTRCTR_ROLE_CD, sep = '_'))

# join test 2/8: sbjct_cd
jointst2 <-left_join(custqs_sbjct, testgrp, by=c("campus","sbjct_cd" = "SBJCT_CD")) %>%
  rowwise() %>%
  mutate(attr2 = ifelse(CATALOG_NBR >= crsmin & CATALOG_NBR <= crsmax, attr, ''))

# join test 10/25: sbjct_cd (need to fix, perhaps filter? distinct?)
custqs_sbjct2 <- custqs_sbjct %>%
    mutate(CATALOG_NBR = map2(crsmin, crsmax, ~ c(.x:.y))) %>%
    unnest(CATALOG_NBR) %>%
    select(-crsmin, -crsmax)

jointst2 <-left_join(session3, custqs_sbjct2, by=c("campus", "SBJCT_CD" = "sbjct_cd", "CATALOG_NBR")) %>%
#  rowwise() %>%
  rename(attr2 = attr) %>%
  rename(fcqdept = fcqdept.x) %>%
  select(-fcqdept.y, -compCdLst) %>%
  distinct() %>%
  mutate(key = paste(Identifier, INSTRCTR_ROLE_CD, sep = '_'))

# join test 10/26: dept plus compCdLst
jointst3 <-left_join(session3, custqs_dept_sect, by=c("campus","fcqdept")) %>%
#  filter("crseSec_comp_cd" %in% "compCdLst") %>%
  rowwise() %>%
  select(-crsmin, -crsmax, -compCdLst, -sbjct_cd) %>%
  rename(attr3 = attr) %>%
  distinct() %>%
  mutate(key = paste(Identifier, INSTRCTR_ROLE_CD, sep = '_'))

# join test 10/26: dept
jointst4 <-left_join(session3, custqs_dept_sect, by=c("campus","fcqdept")) %>%
  rowwise() %>%
  select(-crsmin, -crsmax, -compCdLst, -sbjct_cd) %>%
  rename(attr4 = attr) %>%
  distinct() %>%
  mutate(key = paste(Identifier, INSTRCTR_ROLE_CD, sep = '_'))

attr2 <- jointst2 %>% select(key, attr2)
attr3 <- jointst3 %>% select(key, attr3)
attr4 <- jointst4 %>% select(key, attr4)

jointst5 <- left_join(jointst1, attr2, by = "key")

# let's export to compare jointst1 and 5 by key to see duplicates and why
# write.csv(jointst1, paste0("K:\\IR\\FCQ\\Prod\\", term_cd, "\\SectionAttribute\\secAttrJ1.csv"), row.names = FALSE)
# write.csv(jointst5, paste0("K:\\IR\\FCQ\\Prod\\", term_cd, "\\SectionAttribute\\secAttrJ5.csv"), row.names = FALSE)


joincust <- cbind(jointst1,jointst2$attr2,jointst3$attr3,jointst4$attr4)
joincust <- joincust %>%
  rename(attr2 = "jointst2$attr2") %>%
  rename(attr3 = "jointst3$attr3") %>%
  rename(attr4 = "jointst4$attr4")

joincust2 <- joincust %>% unite("Key", c(attr1, attr2, attr3, attr4), sep=",", remove = FALSE, na.rm = TRUE)

sectattr <- joincust2 %>%
  select(Identifier, Key) %>%
  mutate(Value = Key)

# combine current session qs with previous custom qs
sectattr_total <- rbind(semqs, sectattr)

write.csv(sectattr_total, paste0('C:\\User\\', userid, '\\OneDrive - UCB-O365\\FCQ - AIM_ Measurement\\CampusLabs\\Imports\\', term_cd, '\\SectionAttribute\\secAttr', term_cd, '.csv'), row.names = FALSE)
