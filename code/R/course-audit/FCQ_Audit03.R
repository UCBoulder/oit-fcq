#########################################################################
# Third stage of FCQ admin setup/course audit sequence
# created: Vince Darcangelo 9/19/22
# most recent update: Vince Darcangelo 6/26/25
# \AIM Measurement - FCQ\R_Code\course_audit\FCQ_Audit03.R
#########################################################################
#'*Set administration dates*
#########################################################################

# adminInd EXCEPTIONS (eligibility changes)
n15 <- n14 %>%
  mutate(adminInd = case_when(
# beijing: update each semester (either 0 for ineligible or comment out if classes are eligible)
#    INSTITUTION_CD == 'CUDEN' & LOC_ID == 'IC_BEIJING' ~ 0,
    SBJCT_CD == 'SLHS' & crseSec_comp_cd == 'PRA' & CATALOG_NBR != '5918' ~ 0,
    SBJCT_CD %in% c('AMBA', 'CLSC', 'EMEA', 'XBUS') ~ 0,
    SBJCT_CD == 'BMSC' & !(CATALOG_NBR %in% c('7812', '7820')) ~ 0,
    INSTITUTION_CD == 'CUDEN' & SBJCT_CD == 'NRSC' & CATALOG_NBR %in% c('7501', '7600', '7610', '7612', '7614', '7615', '7670', '7661') ~ 0,
    INSTITUTION_CD == 'CUDEN' & SBJCT_CD == 'PHCL' & CATALOG_NBR == '7620' ~ 0,
    SBJCT_CD == 'CMFT' & CATALOG_NBR %in% c('5910', '5911', '5930') ~ 0,
    SBJCT_CD == 'COUN' & CATALOG_NBR %in% c('5910', '5911') ~ 0,
    SBJCT_CD == 'EDUC' & CATALOG_NBR %in% c('4513', '4710', '4712', '4720', '4722', '4732', '4901') ~ 0,
    paste(SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, sep = '-') == 'INTS-3939-901' ~ 1,
    fcqdept == 'SASC' & paste(SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, sep = '-') %in% c('ARSC-1710-310R', 'ARSC-1720-310R') ~ 0,
# DN-EDUC exemption for THE course
    campus == 'DN' & paste(SBJCT_CD, CATALOG_NBR, sep = '-') == 'LDFS-6950' ~ 1,
# CE-EDUA exceptions for capstone
    campus == 'CE' & SBJCT_CD == 'EDUA' & CATALOG_NBR %in% c('5003', '5007', '5018', '5022', '5026', '5030', '5034') ~ 1,
# one-time exception for BD-ENES global intensives
#    campus == 'BD' & SBJCT_CD == 'ENES' & CATALOG_NBR == '3844' & CLASS_SECTION_CD == '801' ~ 0,
# one-time exception for DN-ECED
#    campus == 'DN' & paste(SBJCT_CD, CATALOG_NBR, sep = '-') %in% c('ECED-4340', 'ECED-6340', 'LDFS-6420') ~ 0,
    TRUE ~ adminInd
  ))

# set administration dates and date exceptions
n16 <- n15 %>%
  mutate(adminDtTxt = case_when(
    adminInd == 0 ~ '',

# adminDtTxt EXCEPTIONS (date changes)
# preterm BD-LAWS
  # adminInd == 1 & campus == 'BD' & paste(SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, sep = '-') %in% c('LAWS-5211-801', 'LAWS-5646-801', 'LAWS-6109-802', 'LAWS-6866-801', 'LAWS-9025-901') ~ 'Aug 23-Aug 26',
# DN-ICB date changes
#  adminInd == 1 & INSTITUTION_CD == 'CUDEN' & LOC_ID == 'IC_BEIJING' ~ 'Jun 16-Jun 20',
# preterm DN-BUSN
#  adminInd == 1 & campus == 'DN' & paste(SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, sep = '-') == 'BUSN-6530-E01' ~ 'Sep 30-Oct 04',
# CE-SLHS sects
#  adminInd == 1 & campus == 'CE' & SBJCT_CD == 'SLHS' & CATALOG_NBR %in% c(3006, 3116, 4502, 4714) & CLASS_SECTION_CD == 750 ~ 'Jul 15-Jul 19',
# BD-LAWS single crse
#  adminInd == 1 & campus == 'BD' & paste(SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, sep = '-') == 'LAWS-7102-801' ~ 'Mar 10-Mar 14',
# BD-BU mod a
#  adminInd == 1 & campus == 'BD' & SBJCT_CD == 'BCOR' & SESSION_CD == 'B81' ~ 'Feb 24-Feb 28',
# CE-BU mod a
#  adminInd == 1 & campus == 'CE' & SBJCT_CD == 'MBAE' & SESSION_CD == 'BM1' ~ 'Feb 10-Feb 14',
# CE-EDUA error fix
#  adminInd == 1 & campus == 'CE' & SBJCT_CD == 'EDUA' ~ 'Jul 07-Jul 11',
# DN-weekend
#  adminInd == 1 & campus == 'DN' & paste(SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, sep = '-') == 'PSCI-5008-ND1' ~ 'Mar 03-Mar 09',
# BD summer abroad sessions
#  adminInd == 1 & campus == 'BD' & CLASS_NUM == 18845 ~ 'Jun 16-Jun 20',
#  adminInd == 1 & campus == 'BD' & CLASS_NUM == 18852 ~ 'Jul 14-Jul 18',
#  adminInd == 1 & campus == 'BD' & CLASS_NUM == 18855 ~ 'Jun 16-Jun 20',
#  adminInd == 1 & campus == 'BD' & CLASS_NUM == 18856 ~ 'Jun 16-Jun 20',
#  adminInd == 1 & campus == 'BD' & CLASS_NUM == 21493 ~ 'May 27-May 31',
#  adminInd == 1 & campus == 'BD' & CLASS_NUM == 18822 ~ 'Aug 04-Aug 08',
#  adminInd == 1 & campus == 'BD' & CLASS_NUM == 18886 ~ 'Aug 04-Aug 08',
#  adminInd == 1 & campus == 'BD' & CLASS_NUM == 19529 ~ 'Jun 09-Jun 13',
#  adminInd == 1 & campus == 'BD' & CLASS_NUM == 18889 ~ 'Jun 23-Jun 27',
#  adminInd == 1 & campus == 'BD' & CLASS_NUM == 18897 ~ 'Jun 16-Jun 21',
# DN-MATH/CSCI summer
#  adminInd == 1 & campus == 'DN' & SBJCT_CD == 'MATH' & SESSION_CD == 'DMR' ~ 'Jul 21-Jul 25',
#  adminInd == 1 & campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR == '4650' ~ 'Jul 21-Jul 25',
# BD-CSPB summer
#  adminInd == 1 & campus == 'BD' & SBJCT_CD == 'CSPB' ~ 'Aug 04-Aug 08',
# midterm BD-LAWS
#  adminInd == 1 & campus == 'BD' & paste(SBJCT_CD, CATALOG_NBR, sep = '-') == 'LAWS-6213' ~ 'Oct 23-Oct 27',
# DN-EDUC changes
#  adminInd == 1 & campus == 'DN' & paste(SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, sep = '-') == 'SPSY-6420-001' ~ 'Jun 30-Jul 05',
#  adminInd == 1 & campus == 'DN' & paste(SBJCT_CD, CATALOG_NBR, CLASS_SECTION_CD, sep = '-') %in% c('RSEM-6700-901', 'RSEM-7400-901', 'RSEM-7400-902') ~ 'Jul 28-Aug 01',
# BD winter session
#   adminInd == 1 & SESSION_CD == 'BWS' ~ 'Jan 02-Jan 06',
# NCLL courses (spring/fall)
#  adminInd == 1 & SBJCT_CD == 'NCLL' & SESSION_CD == 'DC1' ~ 'Mar 03-Mar 07',
# NCLL courses (summer only)
#  adminInd == 1 & SBJCT_CD == 'NCLL' ~ 'Jul 21-Jul 25',
# DN Cuba Libre courses (spring)
#  adminInd == 1 & paste(SBJCT_CD, CATALOG_NBR, sep = '-') %in% c('MGMT-4028', 'MGMT-6028', 'ENTP-4028', 'ENTP-6028') & SESSION_CD == 'DCV' ~ 'Feb 17-Feb 21',
# OREC wrong dates
#  adminInd == 1 & SBJCT_CD == 'OREC' & SESSION_CD == 'B81' ~ 'Oct 09-Oct 13',

# standard administration dates
  adminInd == 1 & between(fcqEnDt,'08/01/2025','08/19/2025') ~ 'Aug 11-Aug 15',
  adminInd == 1 & between(fcqEnDt,'05/21/2025','05/27/2025') ~ 'May 19-May 23',
  adminInd == 1 & between(fcqEnDt,'05/28/2025','06/03/2025') ~ 'May 27-May 31',
  adminInd == 1 & between(fcqEnDt,'06/04/2025','06/10/2025') ~ 'Jun 02-Jun 06',
  adminInd == 1 & between(fcqEnDt,'06/11/2025','06/17/2025') ~ 'Jun 09-Jun 13',
  adminInd == 1 & between(fcqEnDt,'06/18/2025','06/24/2025') ~ 'Jun 16-Jun 21',
  adminInd == 1 & between(fcqEnDt,'06/25/2025','07/01/2025') ~ 'Jun 23-Jun 27',
  adminInd == 1 & between(fcqEnDt,'07/02/2025','07/08/2025') ~ 'Jun 30-Jul 05',
  adminInd == 1 & between(fcqEnDt,'07/09/2025','07/15/2025') ~ 'Jul 07-Jul 11',
  adminInd == 1 & between(fcqEnDt,'07/16/2025','07/22/2025') ~ 'Jul 14-Jul 18',
  adminInd == 1 & between(fcqEnDt,'07/23/2025','07/29/2025') ~ 'Jul 21-Jul 25',

#  adminInd == 1 & between(fcqEnDt,'07/30/2025','08/05/2025') ~ 'Jul 28-Aug 01',
#  adminInd == 1 & between(fcqEnDt,'08/06/2025','08/12/2025') ~ 'Aug 04-Aug 08',
#  adminInd == 1 & between(fcqEnDt,'08/13/2025','08/31/2025') ~ 'Aug 11-Aug 15'#,
#  adminInd == 1 & between(fcqEnDt,'04/16/2025','04/22/2025') ~ 'Apr 14-Apr 18',
#  adminInd == 1 & between(fcqEnDt,'04/23/2025','04/29/2025') & campus %in% c('DN', 'MC') ~ 'Apr 21-Apr 25',
# ENGR Extended Final
#  adminInd==1 & between(fcqEnDt,'04/23/2025','05/31/2025') & campus == 'BD' & SBJCT_CD %in% c('GEEN', 'ENED') ~ 'Apr 21-May 01',
#  adminInd==1 & between(fcqEnDt,'04/23/2025','05/31/2025') & campus == 'BD' & paste(SBJCT_CD, CATALOG_NBR, sep = '-') == 'MCEN-4085' ~ 'Apr 21-May 01',
# LAWS Early Final
#  adminInd==1 & between(fcqEnDt,'04/23/2025','05/31/2025') & campus == 'BD' & SBJCT_CD == 'LAWS' ~ 'Apr 20-Apr 27',
# Boulder/CEPS Final
#  adminInd==1 & between(fcqEnDt,'04/23/2025','05/31/2025') & campus %in% c('BD', 'CE') ~ 'Apr 21-Apr 29',
# B3 Final
#  adminInd==1 & between(fcqEnDt,'04/23/2025','05/31/2025') & campus == 'B3' ~ 'Apr 21-Apr 29',
# Denver Beijing sections
#  adminInd==1 & fcqEnDt >= '11/22/2025' & campus == 'DN' & LOC_ID == 'IC_BEIJING' ~ 'Nov 18-Dec 03',
# Denver Final
#  adminInd==1 & between(fcqEnDt,'04/30/2025','05/31/2025') & campus == 'DN' & CAMPUS_CD !='AMC' ~ 'Apr 28-May 06',
# AMC Final
#  adminInd==1 & between(fcqEnDt,'04/30/2025','05/31/2025') & campus == 'MC' & CAMPUS_CD =='AMC' ~ 'Apr 28-May 06'
  ))

#############################################################################
# QC: Find missing leading zeros
n16x <- n16 %>%
  filter(nchar(adminDtTxt) > 0 & nchar(adminDtTxt) < 13)

while (TRUE) {
  if (nrow(n16x) == 0) {
    break
  } else {
    View(n16x)
    stop('Review and fix missing leading zeros before continuing')
  }
}

# QC: Find dups with different end dates
n16xx <- n16 %>%
  ungroup() %>%
  select(CLASS_NUM, adminDtTxt) %>%
  distinct() %>%
  filter(adminDtTxt != '') %>%
  group_by(CLASS_NUM) %>%
  filter(n() >= 2)

while (TRUE) {
  if (nrow(n16xx) == 0) {
    break
  } else {
    View(n16xx)
    stop('Review and fix dups with different end dates before continuing')
  }
}

# QC: Find adminInd = 1 with no admin date
n16xxx <- n16 %>%
  ungroup() %>%
  filter(adminInd == 1 & is.na(adminDtTxt))

while (TRUE) {
  if (nrow(n16xxx) == 0) {
    break
  } else {
    View(n16xxx)
    stop('Review and fix classes that get FCQs, but have no run date')
  }
}

#XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX#

# create and format adminStartDt/adminEndDt columns
n17 <- n16 %>%
  mutate(adminStartDt = case_when(
    adminDtTxt != '' ~ substr(adminDtTxt, 1, 6),
    TRUE ~ '')) %>%
  mutate(adminEndDt = case_when(
    adminDtTxt != '' ~ substr(adminDtTxt, 8, 13),
    TRUE ~ '')) %>%
  mutate(adminStartDt = str_replace_all(adminStartDt, ' ', '-')) %>%
  mutate(adminEndDt = str_replace_all(adminEndDt, ' ', '-')) %>%
  mutate(adminStartDt = format(as.Date(adminStartDt, format = '%b-%d'), '%m/%d/%Y')) %>%
  mutate(adminEndDt = format(as.Date(adminEndDt, format = '%b-%d'), '%m/%d/%Y'))

clscu <- n17 %>%
  select(campus,deptOrgID,fcqdept,TERM_CD,INSTITUTION_CD,CAMPUS_CD,SESSION_CD,SBJCT_CD,CATALOG_NBR,CLASS_SECTION_CD,instrNum,instrNm,instrLastNm,instrFirstNm,instrMiddleNm,instrPersonID,instrConstituentID,instrEmplid,instrEmailAddr,INSTRCTR_ROLE_CD,ASSOCIATED_CLASS,assoc_class_secID,GRADE_BASIS_CD,totEnrl_nowd_comb,totEnrl_nowd,ENRL_TOT,ENRL_CAP,ROOM_CAP_REQUEST,CRSE_LD,LOC_ID,CLASS_STAT,crseSec_comp_cd,SSR_COMP_CD,combStat,spons_AcadGrp,spons_AcadOrg,spons_fcqdept,spons_deptOrgID,spons_id,SCTN_CMBND_CD,SCTN_CMBND_LD,INSTRCTN_MODE_CD,CLASS_TYPE,SCHED_PRINT_INSTR,mtgStartDt,mtgEndDt,CLASS_START_DT,CLASS_END_DT,CLASS_NUM,ACAD_GRP_CD,ACAD_GRP_LD,ACAD_ORG_CD,ACAD_ORG_LD,totSchedPrintInstr_Y,totSchedPrintInstr_Not_Y,totInstrPerClass,totCrsePerInstr,totAssocClassPerInstr,indLEC,indNotLEC,totLECInstr,totNotLECInstr,cmbsecInfo,adminInd,fcqNote,indInstrNm,indDIS_IND_THE,indDEPT_RQST,indIndptStdy,indMinEnrl,indCombSect0,indCandDegr,indGiveOnlyLEC,indCrseTooLate,fcqStDt,fcqEnDt,adminDtTxt,adminStartDt,adminEndDt)

clscu <- clscu %>%
  mutate(fcqNote = case_when(
    adminInd == 0 & fcqNote == '' ~ 'No FCQs per department request',
    TRUE ~ fcqNote
  ))

#########################################################################
# attach custom questions - generate code with custQ_parse.R
#########################################################################
clscu2 <- clscu %>%
  mutate(attr1 = case_when(
#    campus == 'BD' & SBJCT_CD == 'AREN' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '4999' ~ 'bd-a-aren-a',
#    campus == 'BD' & SBJCT_CD == 'ASEN' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '4999' ~ 'bd-a-asen-a',
    campus == 'BD' & SBJCT_CD == 'BMEN' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '6999' ~ 'bd-a-bmen-a',
#    campus == 'BD' & SBJCT_CD == 'CHEN' & CATALOG_NBR >= '4810' & CATALOG_NBR <= '4820' ~ 'bd-a-chen-a,bd-a-chen-b',
#    campus == 'BD' & SBJCT_CD == 'CHEN' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '4999' ~ 'bd-a-chen-a',
#    campus == 'BD' & SBJCT_CD == 'COEN' & CATALOG_NBR >= '1000' & CATALOG_NBR #<= '4999' ~ 'bd-a-coen-a',
#    campus == 'BD' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '4999' ~ 'bd-a-csci-a',
#    campus == 'BD' & SBJCT_CD == 'CVEN' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '4999' ~ 'bd-a-cven-d',
#    campus == 'BD' & SBJCT_CD == 'ECEN' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '4999' ~ 'bd-a-ecen-b',
#    campus == 'BD' & SBJCT_CD == 'EVEN' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '8000' ~ 'bd-a-even-a',
#    campus == 'BD' & SBJCT_CD == 'GEEN' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '4999' ~ 'bd-a-geen-a',
    campus == 'BD' & SBJCT_CD == 'ENES' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '4999' ~ 'bd-a-huen-a',
    campus == 'BD' & SBJCT_CD == 'MCEN' & CATALOG_NBR %in% c('1024', '1025', '2000', '2023', '2024', '2043', '2063', '3012', '3017', '3021', '3022', '3025', '3030', '3032', '3047', '4026', '4043', '4045', '4085') ~ 'bd-a-mcen-w',
    campus == 'BD' & SBJCT_CD == 'GEEN' & CATALOG_NBR %in% c('2400', '3010', '3024', '3400', '3852', '3853') ~ 'bd-d-geen-a',
    campus == 'BD' & SBJCT_CD == 'ASIA' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '6999' ~ 'bd-c-asia-a',
    campus == 'BD' & SBJCT_CD == 'CMCI' & CATALOG_NBR >= '1010' & CATALOG_NBR <= '1010' ~ 'bd-c-cmci-a',
    campus == 'BD' & SBJCT_CD == 'CSPB' ~ 'bd-c-cspb-a',
    campus == 'CE' & SBJCT_CD == 'CSPB' ~ 'bd-c-cspb-a',
    campus == 'BD' & SBJCT_CD == 'COMM' & CATALOG_NBR >= '2410' & CATALOG_NBR <= '2410' ~ 'bd-c-comm-a',
    campus == 'BD' & SBJCT_CD == 'EDUC' & CATALOG_NBR >= '2020' & CATALOG_NBR <= '2050' ~ 'bd-c-educ-a',
    campus == 'BD' & SBJCT_CD == 'EDUC' & CATALOG_NBR >= '3013' & CATALOG_NBR <= '3013' ~ 'bd-c-educ-b',
    campus == 'BD' & SBJCT_CD == 'EDUC' & CATALOG_NBR >= '4023' & CATALOG_NBR <= '4112' ~ 'bd-c-educ-c',
    campus == 'BD' & SBJCT_CD == 'EDUC' & CATALOG_NBR >= '4125' & CATALOG_NBR <= '4125' ~ 'bd-c-educ-d',
    campus == 'BD' & SBJCT_CD == 'EDUC' & CATALOG_NBR >= '4222' & CATALOG_NBR <= '4411' ~ 'bd-c-educ-e',
    campus == 'BD' & SBJCT_CD == 'EDUC' & CATALOG_NBR >= '5005' & CATALOG_NBR <= '5060' ~ 'bd-c-educ-f',
    campus == 'BD' & SBJCT_CD == 'EDUC' & CATALOG_NBR >= '5205' & CATALOG_NBR <= '5295' ~ 'bd-c-educ-g',
    campus == 'BD' & SBJCT_CD == 'EDUC' & CATALOG_NBR >= '5315' & CATALOG_NBR <= '5545' ~ 'bd-c-educ-h',
    campus == 'BD' & SBJCT_CD == 'EDUC' & CATALOG_NBR >= '5605' & CATALOG_NBR <= '5635' ~ 'bd-c-educ-i',
    campus == 'BD' & SBJCT_CD == 'EDUC' & CATALOG_NBR >= '6368' & CATALOG_NBR <= '6368' ~ 'bd-c-educ-j',
    campus == 'BD' & SBJCT_CD == 'ENGL' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '4999' ~ 'bd-c-engl-a',
    campus == 'BD' & SBJCT_CD == 'ENVM' & CATALOG_NBR >= '6002' & CATALOG_NBR <= '6002' ~ 'bd-c-envm-a',
    campus == 'BD' & SBJCT_CD == 'ENVM' & CATALOG_NBR >= '5018' & CATALOG_NBR <= '5018' ~ 'bd-c-envm-b',
    campus == 'BD' & CLASS_SECTION_CD >= '880' & CLASS_SECTION_CD <= '883' ~ 'bd-c-honr-a',
    campus == 'BD' & SBJCT_CD == 'ENES' & CATALOG_NBR >= '3350' & CATALOG_NBR <= '3350' ~ 'bd-c-huen-a',
    campus == 'BD' & SBJCT_CD == 'INVS' & CATALOG_NBR >= '2989' & CATALOG_NBR <= '2989' ~ 'bd-c-invs-a',
    campus == 'BD' & SBJCT_CD == 'IPHY' & CATALOG_NBR >= '3415' & CATALOG_NBR <= '3415' ~ 'bd-c-iphy-b',
    campus == 'BD' & SBJCT_CD == 'IPHY' & CATALOG_NBR >= '3435' & CATALOG_NBR <= '3435' ~ 'bd-c-iphy-c',
    campus == 'BD' & SBJCT_CD == 'ITAL' & CATALOG_NBR >= '1010' & CATALOG_NBR <= '1010' ~ 'bd-c-ital-a',
    campus == 'BD' & SBJCT_CD == 'ITAL' & CATALOG_NBR >= '1020' & CATALOG_NBR <= '1020' ~ 'bd-c-ital-b',
    campus == 'BD' & SBJCT_CD == 'ITAL' & CATALOG_NBR >= '1050' & CATALOG_NBR <= '1050' ~ 'bd-c-ital-c',
    campus == 'BD' & SBJCT_CD == 'ITAL' & CATALOG_NBR >= '2110' & CATALOG_NBR <= '2110' ~ 'bd-c-ital-d',
    campus == 'BD' & SBJCT_CD == 'ITAL' & CATALOG_NBR >= '2120' & CATALOG_NBR <= '2120' ~ 'bd-c-ital-e',
    campus == 'BD' & SBJCT_CD == 'PMUS' & CATALOG_NBR >= '1636' & CATALOG_NBR <= '1636' ~ 'bd-c-pmus-a,bd-c-pmus-b',
    campus == 'BD' & SBJCT_CD == 'PMUS' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '6999' ~ 'bd-c-pmus-b',
    campus == 'BD' & SBJCT_CD == 'ATOC' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '1999' ~ 'bd-d-atoc-a',
    campus == 'CE' & SBJCT_CD == 'ECON' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '6999' ~ 'ce-c-econ-a',
    campus == 'CE' & SBJCT_CD == 'ESLG' & CATALOG_NBR >= '1130' & CATALOG_NBR <= '1130' ~ 'ce-c-eslg-a',
    campus == 'CE' & SBJCT_CD == 'ESLG' & CATALOG_NBR >= '1140' & CATALOG_NBR <= '1140' ~ 'ce-c-eslg-b',
    campus == 'CE' & SBJCT_CD == 'ESLG' & CATALOG_NBR >= '1210' & CATALOG_NBR <= '1210' ~ 'ce-c-eslg-c',
    campus == 'CE' & SBJCT_CD == 'ESLG' & CATALOG_NBR >= '1222' & CATALOG_NBR <= '1222' ~ 'ce-c-eslg-d',
    campus == 'CE' & SBJCT_CD == 'ESLG' & CATALOG_NBR >= '1410' & CATALOG_NBR <= '1410' ~ 'ce-c-eslg-e',
    campus == 'CE' & SBJCT_CD == 'NCIE' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '6999' ~ 'ce-c-ncie-a',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '3415' & CATALOG_NBR <= '3415' ~ 'dn-a-csci-aa',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '3453' & CATALOG_NBR <= '3453' ~ 'dn-a-csci-ab',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '3508' & CATALOG_NBR <= '3508' ~ 'dn-a-csci-ac',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '3511' & CATALOG_NBR <= '3511' ~ 'dn-a-csci-ad',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '3560' & CATALOG_NBR <= '3560' ~ 'dn-a-csci-ae',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '3761' & CATALOG_NBR <= '3761' ~ 'dn-a-csci-af',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '4034' & CATALOG_NBR <= '4034' ~ 'dn-a-csci-ag',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '4110' & CATALOG_NBR <= '4110' ~ 'dn-a-csci-ah',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '4287' & CATALOG_NBR <= '4287' ~ 'dn-a-csci-ai',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '4455' & CATALOG_NBR <= '4455' ~ 'dn-a-csci-aj',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '4551' & CATALOG_NBR <= '4551' ~ 'dn-a-csci-ak',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '4565' & CATALOG_NBR <= '4565' ~ 'dn-a-csci-al',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '4580' & CATALOG_NBR <= '4580' ~ 'dn-a-csci-am',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '4591' & CATALOG_NBR <= '4591' ~ 'dn-a-csci-an',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '4650' & CATALOG_NBR <= '4650' ~ 'dn-a-csci-ao',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '4738' & CATALOG_NBR <= '4739' ~ 'dn-a-csci-ap',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '4741' & CATALOG_NBR <= '4743' ~ 'dn-a-csci-aq',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '4930' & CATALOG_NBR <= '4931' ~ 'dn-a-csci-ar',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '4951' & CATALOG_NBR <= '4951' ~ 'dn-a-csci-as',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '2525' & CATALOG_NBR <= '2525' ~ 'dn-a-csci-at',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '1410' & CATALOG_NBR <= '1411' ~ 'dn-a-csci-s',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '1510' & CATALOG_NBR <= '1510' ~ 'dn-a-csci-t',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '2312' & CATALOG_NBR <= '2312' ~ 'dn-a-csci-u',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '2421' & CATALOG_NBR <= '2421' ~ 'dn-a-csci-v',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '2511' & CATALOG_NBR <= '2511' ~ 'dn-a-csci-w',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '3287' & CATALOG_NBR <= '3287' ~ 'dn-a-csci-y',
    campus == 'DN' & SBJCT_CD == 'CSCI' & CATALOG_NBR >= '3412' & CATALOG_NBR <= '3412' ~ 'dn-a-csci-z',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '3030' & CATALOG_NBR <= '3030' ~ 'dn-a-elec-ai',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '3215' & CATALOG_NBR <= '3215' ~ 'dn-a-elec-al',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4025' & CATALOG_NBR <= '4025' ~ 'dn-a-elec-at',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4133' & CATALOG_NBR <= '4133' ~ 'dn-a-elec-au',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4134' & CATALOG_NBR <= '4134' ~ 'dn-a-elec-av',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4184' & CATALOG_NBR <= '4184' ~ 'dn-a-elec-ay',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4225' & CATALOG_NBR <= '4225' ~ 'dn-a-elec-az',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4248' & CATALOG_NBR <= '4248' ~ 'dn-a-elec-ba',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4276' & CATALOG_NBR <= '4276' ~ 'dn-a-elec-bb',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4309' & CATALOG_NBR <= '4309' ~ 'dn-a-elec-bc',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4319' & CATALOG_NBR <= '4319' ~ 'dn-a-elec-bd',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4406' & CATALOG_NBR <= '4406' ~ 'dn-a-elec-bf',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4423' & CATALOG_NBR <= '4423' ~ 'dn-a-elec-bg',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4435' & CATALOG_NBR <= '4435' ~ 'dn-a-elec-bh',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4444' & CATALOG_NBR <= '4444' ~ 'dn-a-elec-bi',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4474' & CATALOG_NBR <= '4474' ~ 'dn-a-elec-bj',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4637' & CATALOG_NBR <= '4637' ~ 'dn-a-elec-bk',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4723' & CATALOG_NBR <= '4723' ~ 'dn-a-elec-bl',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4727' & CATALOG_NBR <= '4727' ~ 'dn-a-elec-db',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '5710' & CATALOG_NBR <= '5710' ~ 'dn-a-elec-bq',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4174' & CATALOG_NBR <= '4174' ~ 'dn-a-elec-br',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4555' & CATALOG_NBR <= '4555' ~ 'dn-a-elec-bs',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '5755' & CATALOG_NBR <= '5755' ~ 'dn-a-elec-bt',
#    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4005' & CATALOG_NBR <= '4005' ~ 'dn-a-elec-bu',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '5194' & CATALOG_NBR <= '5194' ~ 'dn-a-elec-bz',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '5294' & CATALOG_NBR <= '5294' ~ 'dn-a-elec-ca',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4375' & CATALOG_NBR <= '4375' ~ 'dn-a-elec-cd',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '1520' & CATALOG_NBR <= '1520' ~ 'dn-a-elec-bv',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '2132' & CATALOG_NBR <= '2132' ~ 'dn-a-elec-cf',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '2142' & CATALOG_NBR <= '2142' ~ 'dn-a-elec-cg',
#    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '2520' & CATALOG_NBR <= '2520' ~ 'dn-a-elec-ch',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '2531' & CATALOG_NBR <= '2531' ~ 'dn-a-elec-ci',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '3133' & CATALOG_NBR <= '3133' ~ 'dn-a-elec-cj',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '3225' & CATALOG_NBR <= '3225' ~ 'dn-a-elec-cl',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '3316' & CATALOG_NBR <= '3316' ~ 'dn-a-elec-cm',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '3520' & CATALOG_NBR <= '3520' ~ 'dn-a-elec-cn',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '3701' & CATALOG_NBR <= '3701' ~ 'dn-a-elec-co',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '3724' & CATALOG_NBR <= '3724' ~ 'dn-a-elec-cp',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '3817' & CATALOG_NBR <= '3817' ~ 'dn-a-elec-cv',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '3900' & CATALOG_NBR <= '3900' ~ 'dn-a-elec-cr',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '1510' & CATALOG_NBR <= '1510' ~ 'dn-a-elec-cs',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '2651' & CATALOG_NBR <= '2651' ~ 'dn-a-elec-ct',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '3164' & CATALOG_NBR <= '3164' ~ 'dn-a-elec-cu',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR %in% c('4164', '5164') ~ 'dn-a-elec-cw',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '4136' & CATALOG_NBR <= '4136' ~ 'dn-a-elec-cx',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR %in% c('4170', '5170') ~ 'dn-a-elec-cy',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '5446' & CATALOG_NBR <= '5446' ~ 'dn-a-elec-cz',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR >= '2520' & CATALOG_NBR <= '2520' ~ 'dn-a-elec-da',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR %in% c('4005', '5005') ~ 'dn-a-elec-dd',
    campus == 'DN' & SBJCT_CD == 'ELEC' & CATALOG_NBR == '5335' ~ 'dn-a-elec-de',
  campus == 'DN' & SBJCT_CD == 'ENGR' & CATALOG_NBR >= '3400' & CATALOG_NBR <= '3400' ~ 'dn-a-engr-a',
    campus == 'DN' & SBJCT_CD == 'ENGL' & CATALOG_NBR >= '1020' & CATALOG_NBR <= '1020' ~ 'dn-c-engl-a',
    campus == 'DN' & SBJCT_CD == 'ENGL' & CATALOG_NBR >= '2030' & CATALOG_NBR <= '2030' ~ 'dn-c-engl-b',
    TRUE ~ '')) %>%
  mutate(attr2 = case_when(
    campus == 'BD' & SBJCT_CD == 'COEN' & CATALOG_NBR == '1830' ~ 'bd-a-coen-b',
  campus == 'BD' & SBJCT_CD == 'FILM' & CATALOG_NBR >= '1000' & CATALOG_NBR <= '4999' & crseSec_comp_cd %in% c('LEC', 'SEM', 'WKS') ~ 'bd-c-film-a',
    campus == 'BD' & SBJCT_CD == 'IPHY' & CATALOG_NBR >= '3060' & CATALOG_NBR <= '3060' & crseSec_comp_cd %in% c('LAB') ~ 'bd-c-iphy-a',
    campus == 'BD' & SBJCT_CD == 'PHYS' & CATALOG_NBR >= '1020' & CATALOG_NBR <= '1020' & crseSec_comp_cd %in% c('LAB', 'REC') ~ 'bd-c-phys-a',
    campus == 'BD' & SBJCT_CD == 'PHYS' & CATALOG_NBR >= '1110' & CATALOG_NBR <= '1110' & crseSec_comp_cd %in% c('REC') ~ 'bd-c-phys-b, bd-c-phys-g',
    campus == 'BD' & SBJCT_CD == 'PHYS' & CATALOG_NBR >= '1120' & CATALOG_NBR <= '1120' & crseSec_comp_cd %in% c('REC') ~ 'bd-c-phys-c,bd-c-phys-h',
    campus == 'BD' & SBJCT_CD == 'PHYS' & CATALOG_NBR >= '1140' & CATALOG_NBR <= '1140' & crseSec_comp_cd %in% c('LAB', 'REC') ~ 'bd-c-phys-d',
    campus == 'BD' & SBJCT_CD == 'PHYS' & CATALOG_NBR >= '2010' & CATALOG_NBR <= '2010' & crseSec_comp_cd %in% c('LAB', 'REC') ~ 'bd-c-phys-e',
    campus == 'BD' & SBJCT_CD == 'PHYS' & CATALOG_NBR >= '2020' & CATALOG_NBR <= '2020' & crseSec_comp_cd %in% c('LAB', 'REC') ~ 'bd-c-phys-f',
    campus == 'BD' & SBJCT_CD == 'PHYS' & CATALOG_NBR >= '1115' & CATALOG_NBR <= '1115' & crseSec_comp_cd %in% c('REC') ~ 'bd-c-phys-i',
    campus == 'BD' & SBJCT_CD == 'PHYS' & CATALOG_NBR >= '1125' & CATALOG_NBR <= '1125' & crseSec_comp_cd %in% c('REC') ~ 'bd-c-phys-j',
    campus == 'DN' & SBJCT_CD == 'PUAD' & CATALOG_NBR >= '5001' & CATALOG_NBR <= '5001' & crseSec_comp_cd %in% c('LEC', 'SEM') ~ 'dn-a-puad-a',
    campus == 'DN' & SBJCT_CD == 'PUAD' & CATALOG_NBR >= '5002' & CATALOG_NBR <= '5002' & crseSec_comp_cd %in% c('LEC') ~ 'dn-a-puad-b',
    campus == 'DN' & SBJCT_CD == 'PUAD' & CATALOG_NBR >= '5003' & CATALOG_NBR <= '5003' & crseSec_comp_cd %in% c('LEC', 'SEM') ~ 'dn-a-puad-c',
    campus == 'DN' & SBJCT_CD == 'PUAD' & CATALOG_NBR >= '5004' & CATALOG_NBR <= '5004' & crseSec_comp_cd %in% c('LEC', 'SEM') ~ 'dn-a-puad-d',
    TRUE ~ '')) %>%
    mutate(attr3 = case_when(
    campus == 'BD' & fcqdept == 'ASEN' ~ 'bd-d-asen-c',
    campus == 'BD' & fcqdept == 'ATLS' ~ 'bd-d-atls-a',
#    campus == 'BD' & fcqdept == 'CHEN' ~ 'bd-d-chen-b',
    campus == 'BD' & fcqdept == 'COMR' ~ 'bd-d-comr-a',
    campus == 'BD' & fcqdept == 'ECON' ~ 'bd-d-econ-a,bd-d-econ-c',
    campus == 'BD' & fcqdept == 'FYSM' ~ 'bd-d-fysm-a',
#    campus == 'BD' & fcqdept == 'GEEN' ~ 'bd-d-geen-a',
    campus == 'BD' & fcqdept == 'HIST' ~ 'bd-d-hist-d',
    campus == 'BD' & fcqdept == 'HRAP' ~ 'bd-d-hrap-a,bd-d-raps-a',
    campus == 'BD' & fcqdept == 'ENES' ~ 'bd-d-huen-c',
    campus == 'BD' & fcqdept == 'LW' ~ 'bd-d-laws-a',
    campus == 'BD' & fcqdept == 'MASP' ~ 'bd-d-masp-a',
    campus == 'BD' & fcqdept == 'PHYS' ~ 'bd-d-phys-a',
    campus == 'BD' & fcqdept == 'PSYC' ~ 'bd-d-psyc-a,bd-d-psyc-b',
    campus == 'BD' & fcqdept %in% c('BRAP', 'FARR', 'GSAP', 'HPRP', 'LIBB', 'SEWL') ~ 'bd-d-raps-a',
    campus == 'BD' & fcqdept == 'SASC' ~ 'bd-d-sasc-a,bd-d-sasc-c,bd-d-sasc-e',
    campus == 'BD' & fcqdept == 'SLHS' ~ 'bd-d-slhs-a',
    campus == 'CE' & fcqdept == 'CC' ~ 'ce-d-cc-a',
    campus == 'CE' & fcqdept == 'CONT' ~ 'ce-d-cont-a',
    campus == 'DN' & fcqdept == 'BIOL' ~ 'dn-d-biol-c',
    campus == 'DN' & fcqdept == 'CVEN' ~ 'dn-d-cven-a',
    campus == 'DN' & fcqdept == 'EDUC' ~ 'dn-d-educ-a',
    campus == 'DN' & fcqdept == 'GEOG' ~ 'dn-d-geog-a',
    campus == 'DN' & fcqdept == 'GEOL' ~ 'dn-d-geol-a',
    campus == 'DN' & fcqdept == 'PHIL' ~ 'dn-d-phil-a',
    TRUE ~ '')) %>%
    mutate(attr4 = case_when(
    campus == 'BD' & fcqdept == 'CHEN' & crseSec_comp_cd %in% c('LEC', 'LAB', 'REC') ~ 'bd-d-chen-a',
    campus == 'BD' & fcqdept == 'ECON' & crseSec_comp_cd %in% c('LEC', 'SEM') ~ 'bd-d-econ-b',
    campus == 'BD' & fcqdept == 'GEOG' & crseSec_comp_cd %in% c('LAB', 'REC') ~ 'bd-d-geog-a',
    campus == 'BD' & fcqdept == 'NAVR' & crseSec_comp_cd %in% c('LEC') ~ 'bd-d-navr-a',
    campus == 'DN' & fcqdept == 'BIOE' & crseSec_comp_cd %in% c('LEC') ~ 'dn-d-bioe-a',
    campus == 'DN' & fcqdept == 'CMMU' & crseSec_comp_cd %in% c('LEC', 'REC', 'SEM') ~ 'dn-d-comm-a',
    TRUE ~ ''))

# reduce to single attr col that may include multiple question sets
clscu3 <- clscu2 %>%
  mutate(sect_attr = case_when(
    attr1 != '' & attr2 == '' & attr3 == '' & attr4 == '' ~ attr1,
    attr1 != '' & attr2 == '' & attr3 != '' & attr4 == '' ~ paste(attr1, attr3, sep = ','),
    attr1 != '' & attr2 == '' & attr3 == '' & attr4 != '' ~ paste(attr1, attr4, sep = ','),
    attr1 != '' & attr2 == '' & attr3 != '' & attr4 != '' ~ paste(attr1, attr3, attr4, sep = ','),
    attr1 != '' & attr2 != '' & attr3 == '' & attr4 == '' ~ paste(attr1, attr2, sep = ','),
    attr1 != '' & attr2 != '' & attr3 != '' & attr4 == '' ~ paste(attr1, attr2, attr3, sep = ','),
    attr1 != '' & attr2 != '' & attr3 != '' & attr4 != '' ~ paste(attr1, attr2, attr3, attr4, sep = ','),
    attr1 == '' & attr2 != '' & attr3 == '' & attr4 == '' ~ attr2,
    attr1 == '' & attr2 != '' & attr3 != '' & attr4 == '' ~ paste(attr2, attr3, sep = ','),
    attr1 == '' & attr2 != '' & attr3 == '' & attr4 != '' ~ paste(attr2, attr4, sep = ','),
    attr1 == '' & attr2 != '' & attr3 != '' & attr4 != '' ~ paste(attr2, attr3, attr4, sep = ','),
    attr1 == '' & attr2 == '' & attr3 != '' & attr4 == '' ~ attr3,
    attr1 == '' & attr2 == '' & attr3 != '' & attr4 != '' ~ paste(attr3, attr4, sep = ','),
    attr1 == '' & attr2 == '' & attr3 == '' & attr4 != '' ~ attr4,
    TRUE ~ '' )) %>%
  select(-c(attr1, attr2, attr3, attr4))

# print
write.csv(clscu3, paste0(folder, 'CourseAudit_bak\\', term_cd, '\\clscu_r.csv'), row.names = FALSE)
