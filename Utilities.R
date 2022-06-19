
library(tidyverse)
library(stringr)
library(lubridate)
library(RPostgreSQL)
library(fuzzyjoin)
library(kableExtra)
library(formattable)
library(reactable)
library(scales)
library(forcats)
library(gt)

options(scipen = 999)

# Set the opening balance 
# FY22
tran.ob <- 910.41
save.ob <- 43323.57

# FY21
# tran.ob <- 681.37
# save.ob <- 31907.85

# FY20
#tran.ob <- 198.06
#save.ob <- 26316.85

# Set the report starting date
rpt.open <- as.Date('2021-04-01', origin = '1970-01-01')
rpt.close <- as.Date('2022-03-31', origin = '1970-01-01')
rpt.fy <- "FY22"

py.open <- zoo::as.Date(zoo::as.yearmon(rpt.open) - 1, frac = 0)
py.close <- zoo::as.Date(zoo::as.yearmon(rpt.close) - 1, frac = 0) 
py.fy <- paste0("FY", as.numeric(str_replace_all(rpt.fy, "FY", "")) - 1)
  

# Load bank statement check
# This file contains the closing balances of 
bs.check <- read_csv(paste0("C:/Users/Blake/Documents/CBVA/Finance/", rpt.fy, "/PROC/bank_balance.csv"))
py.bs.check <- read_csv(paste0("C:/Users/Blake/Documents/CBVA/Finance/", py.fy, "/PROC/bank_balance.csv"))

# Generate a table of dates
rpt.dates <- tibble(curr = seq(rpt.open, length = 13, by = "months") - 1) %>% 
  mutate(prev = lag(curr)) %>% 
  filter(!is.na(prev)) %>% 
  mutate(id = row_number()) %>% 
  select(id, prev, curr)

py.dates <- tibble(curr = seq(py.open, length = 13, by = "months") - 1) %>% 
  mutate(prev = lag(curr)) %>% 
  filter(!is.na(prev)) %>% 
  mutate(id = row_number()) %>% 
  select(id, prev, curr)


# Set Reporting Month
rpt.id <- bs.check %>% filter(!is.na(bank_tran)) %>% summarise(id = max(rpt_id)) %>% unlist()

rpt.curr <- rpt.dates$curr[rpt.id]
rpt.prev <- rpt.dates$prev[rpt.id]

py.curr <- py.dates$curr[rpt.id]
py.prev <- py.dates$prev[rpt.id]

func_getTibble <- function(strSQL){
  
  dbGetQuery(conn, strSQL) %>% 
    as_tibble()
  
}

func_printTable <- function(inputData, inputDigits, inputNames, inputCaption, boldFlag = F, boldRows = 1) {
  
  x <- kable(inputData
             , format = "html"
             , format.args = list(big.mark = ",")
             , digits = inputDigits
             , col.names = inputNames
             , caption = inputCaption) %>% 
    kable_styling(bootstrap_options = c("striped", "hover"), full_width = F, font_size = 12)
  
  if (boldFlag) {
    x <- x %>% row_spec(boldRows, bold = T)
  }
  
  return(x)
  
}

func_ggtheme <- function(setHjust = NULL, showAxisX = TRUE) {
  
  if (showAxisX) {
    
    ggtheme <- theme(axis.title = element_text(size = 9, colour = "grey80")
                     , axis.text.x = element_text(size = 8, colour = "grey80")
                     , axis.text.y = element_text(size = 8, colour = "grey80", angle = 0)
                     , panel.background = element_rect(fill = "#002A52", colour = NA)
                     , plot.background = element_rect(fill = "#002A52", colour = NA)
                     , panel.border = element_rect(fill = "transparent", colour = "#002A52")
                     , panel.grid.major = element_blank()
                     , panel.grid.minor = element_blank()
                     , legend.background = element_rect(fill = "transparent", colour = NA)
                     , legend.box.background = element_rect(fill = "transparent", colour = NA)
                     , axis.line = element_blank()
                     , axis.ticks = element_blank()
                     , legend.title = element_text(size = 8, colour = "grey80")
                     , legend.text = element_text(size = 7, colour = "grey80")
                     , legend.key = element_rect(fill = NA)
                     , plot.subtitle = element_text(size = 10, colour = "white")
                     , plot.title = element_text(size = 14, colour = "white")
                     , strip.background = element_blank()
                     , strip.text = element_text(size = 9, colour = "white", hjust = setHjust))
    
    
  } else {
    
    ggtheme <- theme(axis.title = element_text(size = 9, colour = "grey80")
                     , axis.text.x = element_text(size = 8, colour = "grey80")
                     , axis.text.y = element_blank()
                     , panel.background = element_rect(fill = "#002A52", colour = NA)
                     , plot.background = element_rect(fill = "#002A52", colour = NA)
                     , panel.border = element_rect(fill = "transparent", colour = "#002A52")
                     , panel.grid.major = element_blank()
                     , panel.grid.minor = element_blank()
                     , legend.background = element_rect(fill = "transparent", colour = NA)
                     , legend.box.background = element_rect(fill = "transparent", colour = NA)
                     , axis.line = element_blank()
                     , axis.ticks = element_blank()
                     , legend.title = element_text(size = 8, colour = "grey80")
                     , legend.text = element_text(size = 7, colour = "grey80")
                     , legend.key = element_rect(fill = NA)
                     , plot.subtitle = element_text(size = 10, colour = "white")
                     , plot.title = element_text(size = 14, colour = "white")
                     , strip.background = element_blank()
                     , strip.text = element_text(size = 9, colour = "white", hjust = setHjust))
    
  }
  
  return(ggtheme)
  
}

# Connect to PostgreSQL
drv <- dbDriver("PostgreSQL")
conn <- dbConnect(drv, dbname = "cbva", host = "localhost", user = "postgres", password = "password")

mnth.ref <- tibble(lvl = 1:12
                   , lbl = c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
                   , full_lbl = c("January", "February", "March", "April", "May", "June"
                                  , "July","August", "September", "October", "November", "December"))

rpt.mnth.full <- mnth.ref %>% filter(lvl == month(rpt.curr)) %>% select(full_lbl) %>% unlist()

# Load reference tables
## Load transaction matching table
cat.ref <- read_csv("C:/Users/Blake/Documents/CBVA/Finance/MAST/category_master.csv")

# Load manual adjustments for 
bank.tran.manual <- read_csv("C:/Users/Blake/Documents/CBVA/Finance/MAST/manual_adjustments.csv")

# Load manual journals
manual.journals <- read_csv("C:/Users/Blake/Documents/CBVA/Finance/MAST/manual_journals.csv")

# Coaches table
coaches.ref <- tibble(coach_id = c("MARCOS", "JOE", "HERNAN", "MLADEN")
                      , coach_descr = c("Marcos", "Joe", "Hernan Terrazzino", "Mladen Stankovic"))

# Notes to the financials
fs.notes <- read_csv("C:/Users/Blake/Documents/CBVA/Finance/MAST/fs_notes.csv")

# Load coaches rates
coach.rates <- read_csv("C:/Users/Blake/Documents/CBVA/Finance/MAST/coach_rates.csv")

grepl.linked.acc <- "*0000412861536*"
grepl.interest <- "Credit Interest"
grepl.paypal <- "Paypal Australia"
#grepl.stripe <- "Stripe Stripe"
grepl.revsport <- "Perpetual Cbva"

save.linked.acc <- "*0000455800733*"

# Read in the CSV file that maps the admin costs and equipment costs
map_admin.raw <- read_csv("C:/Users/Blake/Documents/CBVA/Finance/MAST/map_admin.csv")
map_equip.raw <- read_csv("C:/Users/Blake/Documents/CBVA/Finance/MAST/map_equip.csv")

cb <- function(df, sep="\t", dec=",", max.size=(200*1000)) {
  
  # Copy a data.frame to clipboard
  write.table(df, paste0("clipboard-", formatC(max.size, format="f", digits=0)), sep=sep, row.names=FALSE, dec=dec)

}