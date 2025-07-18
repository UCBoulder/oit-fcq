org <- read.csv("K:\\IR\\FCQ\\Prod\\2227\\Enrollment\\stuEnrl2227__batch16b3.csv")
cor <- read.csv("K:\\IR\\FCQ\\Prod\\2227\\Enrollment\\stuEnrl2227__batch56.csv")

org2 <- org %>%
  mutate(SectionIdentifier = tolower(SectionIdentifier))

fix <- anti_join(org2, cor, by = c("PersonIdentifier", "SectionIdentifier"))
fix2 <- fix %>%
  mutate(Status = "Dropped")

write.csv(fix2, paste0("K:\\IR\\FCQ\\Prod\\2227\\Enrollment\\stuEnrlB3_drop.csv"), row.names = FALSE)
