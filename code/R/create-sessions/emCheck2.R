#########################################################################
# Fix missing pref_emails for students when building CL import files
# created: Vince Darcangelo 3/21/25
# most recent update: Vince Darcangelo 7/18/25
# \AIM Measurement - FCQ\R_Code\campus_labs\emCheck2.R
#########################################################################

### FIX emCheck2
stuAcct3 <- stuAcct %>%
  select(stuConstituentID, stuFirstNm, stuLastNm, PREF_EMAIL, BLD_EMAIL, CONT_ED_EMAIL, DEN_EMAIL)

### pull PREF_EMAIL if exists, else pull campus email
stuAcct4 <- stuAcct3 %>%
  mutate(Email = case_when(
    PREF_EMAIL %in% c("","-") & INSTITUTION_CD == "CUBLD" ~ BLD_EMAIL,
    PREF_EMAIL %in% c("","-") & CAMPUS_CD == "CEPS" & CONT_ED_EMAIL != "-" ~ CONT_ED_EMAIL,
    PREF_EMAIL %in% c("","-") & CAMPUS_CD == "CEPS" & BLD_EMAIL != "-" ~ BLD_EMAIL,
    PREF_EMAIL %in% c("","-") & INSTITUTION_CD == "CUDEN" ~ DEN_EMAIL,
    TRUE ~ PREF_EMAIL
  ))

### error check for missing emails
stu_missing <- stuAcct4 %>%
  filter(PREF_EMAIL %in% c("","-"))

### if stu_missing == 0, else manually look up and add student email
stuAcct_import <- stuAcct4 %>%
  select(stuConstituentID, stuFirstNm, stuLastNm, Email)
colnames(stuAcct_import) <- c("PersonIdentifier", "FirstName", "LastName", "Email")

### remove erroneous entry (e.g., stuConstituentID == 'DISCARDED@cu.edu')
stuAcct_import <- stuAcct_import %>%
  filter(PersonIdentifier != 'DISCARDED@cu.edu')
