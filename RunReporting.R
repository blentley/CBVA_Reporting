
## Clear the environment
rm(list = ls())

## Set your working directory
proj.dir <- "C:/Users/Blake/Documents/CBVA/Finance/"
setwd(proj.dir)

fn <- "CBVA_May2022.html"

rmarkdown::render(input = "WIP_Reporting.Rmd"
                  , output_format = "html_document"
                  , output_dir = "C:/Users/Blake/Documents/CBVA/Finance/FY23/OUT/"
                  , output_file = fn)