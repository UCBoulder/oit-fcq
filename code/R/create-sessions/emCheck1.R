#########################################################################
# Fix missing pref_emails for instructors when building CL import files
# created: Vince Darcangelo 3/21/25
# most recent update: Vince Darcangelo 7/18/25
# \AIM Measurement - FCQ\R_Code\campus_labs\emCheck1.R
#########################################################################

### FIX emCheck1
instAcct2 <- session %>%
  filter(instrEmailAddr %in% c('','-')) %>%
  ungroup() %>%
  select(instrPersonID, instrConstituentID, instrFirstNm, instrLastNm, CAMPUS_CD) %>%
  mutate(instrConstituentID = paste0(instrConstituentID, "@cu.edu")) %>%
  left_join(em, 'instrPersonID')

### pull PREF_EMAIL if exists, else pull campus email
instAcct3 <- instAcct2 %>%
  mutate(Email = case_when(
    PREF_EMAIL %in% c('','-') & CAMPUS_CD %in% c('BLD3' , 'BLDR') ~ BLD_EMAIL,
    PREF_EMAIL %in% c('','-') & CAMPUS_CD == 'CEPS' & CONT_ED_EMAIL != '-' ~ CONT_ED_EMAIL,
    PREF_EMAIL %in% c('','-') & CAMPUS_CD == 'CEPS' & BLD_EMAIL != '-' ~ BLD_EMAIL,
    PREF_EMAIL %in% c('','-') & CAMPUS_CD %in% c('DC', 'EXSTD', 'AMC') ~ DEN_EMAIL,
    TRUE ~ PREF_EMAIL
  ))

### error check for missing emails
inst_missing <- instAcct3 %>%
  filter(is.na(Email))

### if inst_missing == 0
instAcct_import <- instAcct3 %>%
  select(instrConstituentID, instrFirstNm, instrLastNm, Email)
colnames(instAcct_import) <- c('PersonIdentifier', "FirstName", "LastName", 'Email')
# then return to CL_Imports doc, rerun from emCheck1 ~line 89

### if inst_missing > 0, manually look up and add instructor email
# fix in instAcct_import
instAcct_import <- instAcct_import %>%
  mutate(Email = case_when(
    PersonIdentifier == 'XXXX-11e8-851E-005056945406@cu.edu' ~ 'anthony.songer@colorado.edu',
    TRUE ~ Email
  ))

# also fix in session (to pick up in instcsv)
session <- session %>%
  mutate(instrEmailAddr = case_when(
    instrPersonID == 'XXXXXXXXX' ~ 'anthony.songer@colorado.edu',
    TRUE ~ instrEmailAddr
  ))
