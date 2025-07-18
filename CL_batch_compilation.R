
library(zip)

# get list of folder names
bd_folders <- list.files(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - Documents\\FCQ\\Batch_Reports\\Boulder'), full.names = TRUE)

ce_folders <- list.files(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - Documents\\FCQ\\Batch_Reports\\CEPS'), full.names = TRUE)

dn_folders <- list.files(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - Documents\\FCQ\\Batch_Reports\\Denver'), full.names = TRUE)

mc_folders <- list.files(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - Documents\\FCQ\\Batch_Reports\\MC'), full.names = TRUE)

cs_folders <- list.files(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - Documents\\FCQ\\Batch_Reports\\UCCS'), full.names = TRUE)

# get list of dept names
bd_dept <- list.files(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - Documents\\FCQ\\Batch_Reports\\Boulder'))

ce_dept <- list.files(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - Documents\\FCQ\\Batch_Reports\\CEPS'))

dn_dept <- list.files(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - Documents\\FCQ\\Batch_Reports\\Denver'))

mc_dept <- list.files(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - Documents\\FCQ\\Batch_Reports\\MC'))

cs_dept <- list.files(paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - Documents\\FCQ\\Batch_Reports\\UCCS'))

###########################################################################
# build file_list function
file_list <- function(directory) {
  list.files(directory, full.names = FALSE)
}

bd_files <- lapply(bd_folders, file_list)
bd_files2 <- as.data.frame(cbind(bd_dept, bd_files))
bd_batch <- bd_files2 %>%
  unnest(bd_files) %>%
  mutate(Campus = 'BD') %>%
  mutate(Dept = bd_dept) %>%
  mutate(Filename = bd_files) %>%
  select(Campus, Dept, Filename)

ce_files <- lapply(ce_folders, file_list)
ce_files2 <- as.data.frame(cbind(ce_dept, ce_files))
ce_batch <- ce_files2 %>%
  unnest(ce_files) %>%
  mutate(Campus = 'CE') %>%
  mutate(Dept = ce_dept) %>%
  mutate(Filename = ce_files) %>%
  select(Campus, Dept, Filename)

dn_files <- lapply(dn_folders, file_list)
dn_files2 <- as.data.frame(cbind(dn_dept, dn_files))
dn_batch <- dn_files2 %>%
  unnest(dn_files) %>%
  mutate(Campus = 'DN') %>%
  mutate(Dept = dn_dept) %>%
  mutate(Filename = dn_files) %>%
  select(Campus, Dept, Filename)

mc_files <- lapply(mc_folders, file_list)
mc_files2 <- as.data.frame(cbind(mc_dept, mc_files))
mc_batch <- mc_files2 %>%
  unnest(mc_files) %>%
  mutate(Campus = 'MC') %>%
  mutate(Dept = mc_dept) %>%
  mutate(Filename = mc_files) %>%
  select(Campus, Dept, Filename)

cs_files <- lapply(cs_folders, file_list)
cs_files2 <- as.data.frame(cbind(cs_dept, cs_files))
cs_batch <- cs_files2 %>%
  unnest(cs_files) %>%
  mutate(Campus = 'CS') %>%
  mutate(Dept = cs_dept) %>%
  mutate(Filename = cs_files) %>%
  select(Campus, Dept, Filename)

batch_master <- rbind(bd_batch, ce_batch, dn_batch, mc_batch, cs_batch)

write.xlsx(batch_master, paste0('C:\\Users\\', userid, '\\UCB-O365\\AIM Measurement - Documents\\FCQ\\Batch_Reports\\Batch_Master.xlsx'))