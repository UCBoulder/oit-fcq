#########################################################################
# Generate communication documents for new semester
# created: Vince Darcangelo 8/22/25
# most recent update: Vince Darcangelo 8/25/25
# \OneDrive - UCB-O365\Documents\oit-fcq\code\R\create-sessions\fcq_Comm_Render.R
# ONLY RUN AFTER UPDATING \fcq_Comm_Docs.Rmd
# OUTPUT: \OneDrive - UCB-O365\Documents\oit-fcq\outputs\
#########################################################################

term_cd <- 2257
setwd('~/oit-fcq/code/R/create-sessions/')

rmarkdown::render(
  input = "fcq_Comm_Docs.Rmd",
  output_format = "word_document",
  output_dir = "../../../outputs",
  output_file = paste0(term_cd, "_comm_docs.docx"),
)
