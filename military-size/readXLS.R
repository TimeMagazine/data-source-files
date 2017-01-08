# You'll need XLConnect to read the Excel files
#install.packages("XLConnect")
#install.packages("ggplot2")
library(XLConnect)
library(ggplot2)

# our master output dataframe
active_duty <- data.frame(year=numeric(), month=character(), total=numeric(), officers=numeric(), enlisted=numeric(), stringsAsFactors = FALSE)

# read XLS figures for 1954-1993
filenames <- list.files("data/AD_1954-1993", pattern="*.xls", full.names=TRUE)

# 1954 - 1993
loaddata_54_91 <- function(filename) {
  wb <- loadWorkbook(filename)
  month_year <- getActiveSheetName(wb)
  df <- readWorksheet(wb, sheet=month_year)
  enlisted <- subset(df, df[,1] == "ENLISTED - Total")
  officers <- subset(df, df[,1] == "OFFICERS - Total")
  total <- subset(df, df[,1] == "TOTAL")
  
  #officers <- as.numeric(gsub(",", "", df[10,"Col2"]))
  #total <- as.numeric(gsub(",", "", df[8,"Col2"]))
  #enlisted <- as.numeric(gsub(",", "", df[27,"Col2"]))
  month_year <- strsplit(month_year, " ")
  month <- month_year[[1]][1]
  year <- month_year[[1]][2]
  
  return(list(
    year=as.numeric(year),
    month=month,
    total=as.numeric(gsub(",", "", total$Col2)),
    officers=as.numeric(gsub(",", "", officers$Col2)),
    enlisted=as.numeric(gsub(",", "", enlisted$Col2))
  ))
}

for (filename in filenames) {
  active_duty[NROW(active_duty)+1,] <- loaddata_54_91(filename)
}

# have to cheat for 1991-1993 because it's a freakin' PDF
active_duty[NROW(active_duty)+1,] <- list(
  year=1991,
  month="September",
  total=1985555,
  officers=290879,
  enlisted=1681592
)

active_duty[NROW(active_duty)+1,] <- list(
  year=1992,
  month="September",
  total=1807177,
  officers=273452,
  enlisted=1520828
)

active_duty[NROW(active_duty)+1,] <- list(
  year=1993,
  month="September",
  total=1705103,
  officers=256694,
  enlisted=1435915
)

# 1994 - 2012.
wb <- loadWorkbook("data/AD_Strengths_FY1994-FY2012.xlsx")
worksheets <- getSheets(wb)

loaddata_94_12 <- function(year_month) {
  year <- as.numeric(substr(year_month, 0, 2))
  if (year > 50) {
    year = year + 1900
  } else {
    year = year + 2000
  }
  df <- readWorksheet(wb, sheet=year_month)
  df[is.na(df)] <- 0
  enlisted <- subset(df, df[,1] == "TOTAL ENLISTED")
  officers <- subset(df, df[,1] == "TOTAL OFFICER")
  total <- subset(df, df[,1] == "GRAND TOTAL")

  return(list(
    year=year,
    month="September",
    total=total$DoD.Total,
    officers=officers$DoD.Total,
    enlisted=enlisted$DoD.Total
  ))  
}

#Ignore warnings. Just lots of blank entries in the XLS files
for (worksheet in worksheets) {
  active_duty[NROW(active_duty)+1,] <- loaddata_94_12(worksheet)
}

# another manual fix. The 2002 data has a missing value
active_duty$officers[active_duty$year==2002] <- 222467
active_duty$total[active_duty$year==2002] <- 1411147

wb <- loadWorkbook("data/AD_Strengths_FY2013-FY2015.xlsx")
worksheets <- getSheets(wb)

loaddata_13_15 <- function(year_month) {
  year <- as.numeric(substr(sub(" ", "", year_month), 0, 4))
  df <- readWorksheet(wb, sheet=year_month)
  officers <- subset(df, df[,1] == "TOTAL OFFICER")
  enlisted <- subset(df, df[,1] == "TOTAL ENLISTED")
  total <- subset(df, df[,1] == "GRAND TOTAL")
  
  return(list(
    year=year,
    month="September",
    total=as.numeric(gsub(",", "", total$Col6)),
    officers=as.numeric(gsub(",", "", officers$Col6)),
    enlisted=as.numeric(gsub(",", "", enlisted$Col6))
  ))  
}

for (worksheet in worksheets) {
  active_duty[NROW(active_duty)+1,] <- loaddata_13_15(worksheet)
}

ggplot(active_duty, aes(x=year)) +
  geom_area(aes(y=total), fill="#CC0000") +
  geom_line(aes(y=total, color="black"), size=2) + 
  geom_line(aes(y=enlisted, color="green"), size=1) + 
  geom_line(aes(y=officers, color="brown"), size=1) + 
  scale_color_manual(labels = c("Total", "Officers", "Enlisted"), values = c("black", "blue", "green"), guide_legend(title="Type")) +
  theme(legend.position="bottom") +
  expand_limits(y=0) 

write.csv(active_duty, "clean/active_duty.csv", row.names = FALSE)