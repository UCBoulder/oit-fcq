### Project: repo-name-year <https://github.com/UCBoulder/link-to-repo-here>

### States the main project directory path and stores code to write custom functions used in this repo

#############################################################################
############# Path to project directory #####################################
#############################################################################

### the local path to main project directory 
### so that we can use relative paths in code as in: paste0(project_path, "output/viz_files/presentation.pptx")
data_path = "C:/Users/eryo3113/Desktop/ODA_DS/DS-template-2023/"
project_path = "C:/Users/eryo3113/Desktop/ODA_DS/DS-template-2023/"

### workbench path
# data_path = "/data/posit/shared-projects/DS-template-2023/"
# project_path = "/home/eryo3113/projects/DS-template-2023/"

#############################################################################
############# Helper functions ##############################################
#############################################################################

#############################################################################
### example: GGplot save fxn to keep same parameters across all plots ###

my_ggsave = function(file, projectpath = path) {
  plotpath = paste0(projectpath, "output/visualizations/")
  ggsave(filename=file, device = "png", dpi = 400, path = plotpath, width = 7, height = 5, bg = "white")
}


#############################################################################
### Your second custom function name and summary of purpose

# function code

#############################################################################


