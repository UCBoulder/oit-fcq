
term_cd <- 2257
setwd('~/oit-fcq/code/R/create-sessions/')

rmarkdown::render(
  input = "fcq_Comm_Docs.Rmd",
  output_format = "word_document",
  output_dir = "../../../outputs",
  output_file = paste0(term_cd, "_comm_docs.docx"),
)


