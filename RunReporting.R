
## Clear the environment
rm(list = ls())

## Set your working directory
proj.dir <- "C:/Users/Blake/Documents/CBVA/Finance/"
setwd(proj.dir)

fn <- "CBVA_February2022.html"

rmarkdown::render(input = "Reporting.Rmd"
                  , output_format = "html_document"
                  , output_dir = "C:/Users/Blake/Documents/CBVA/Finance/FY22/OUT/"
                  , output_file = fn)