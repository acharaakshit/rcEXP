library(httr)
library(jsonlite)



#store and structure the data in a dataframe
parent_URL <- "http://cranlogs.r-pkg.org/"
daily_url <- paste0(parent_URL, "downloads/daily/")
top50_url <- paste0(parent_URL, "top")
packages <- "/ggplot"

#to find data between two dates
from <-"2011-01-01" 
to   <- "2012-01-01"
interval <- paste(from,sep = ":" ,to)
response <- GET(paste0(daily_url, interval, packages),
           httr::user_agent("cranlogs R package by R-hub"))

stop_for_status(response)

json_data <- fromJSON(content(response, as = "text"), simplifyVector = FALSE,encoding = "UTF-8")

if(is.null(json_data[[1]][["package"]])){
  
  total_r_downloads <- 0
  freq_r <- c()
  for(x in seq(1,length(json_data[[1]][["downloads"]]),1)){
    freq_r <- c(freq_r, json_data[[1]][["downloads"]][[x]][["downloads"]] )
    total_downloads = total_downloads + json_data[[1]][["downloads"]][[x]][["downloads"]]
  }
  
  print("The total number of R downloads in the interval was : ")
  print(total_r_downloads)
  hist(freq_r)
}else {
  total_package_downloads <- 0
  freq_package <- c()
  for(x in seq(1,length(json_data[[1]][["downloads"]]),1)){
    freq_package <- c(freq_package, json_data[[1]][["downloads"]][[x]][["downloads"]] )
    total_package_downloads = total_package_downloads + json_data[[1]][["downloads"]][[x]][["downloads"]]
  }
  print("The total number of package downloads in the interval was : ")
  print(total_package_downloads)
  plot(freq_package, col="blue", type="b", xlab = "time", ylab = "number of downloads of the package")
}

#to find monthly data
input_year <- readline(prompt = "Enter the year for which you want montly data : ")
months <- c("01","02","03","04","05","06","07","08","09","10","11","12")
for (x in seq(1,12,1)) {
  
  from <- paste(input_year, sep = "-",months[x],"01")
  to <- paste(input_year,sep = "-",months[x],"28")
  interval <- paste(from,sep = ":", to)
  response <- GET(paste0(daily_url, interval, packages),
              httr::user_agent("cranlogs R package by R-hub"))
  
  stop_for_status(response)
  
  json_data <- fromJSON(content(response, as = "text"), simplifyVector = FALSE,encoding = "UTF-8")
  total_package_downloads <- 0
  freq_package <- c()
  for(x in seq(1,length(json_data[[1]][["downloads"]]),1)){
    freq_package <- c(freq_package, json_data[[1]][["downloads"]][[x]][["downloads"]] )
    total_package_downloads = total_package_downloads + json_data[[1]][["downloads"]][[x]][["downloads"]]
  }
  print("The total number of package downloads in the month was : ")
  print(total_package_downloads)
}

#to find yearly data for a period of few years
start_year <- readline(prompt = "Enter the start year of the interval : ")
end_year <- readline(prompt = "Enter the end year of the interval : ")
for (x in seq(as.numeric(start_year),as.numeric(end_year),1)) {
  from <- paste(as.character(x), sep = "-","01","01")
  to <- paste(as.character(x), sep = "-","12","31")
  interval <- paste(from,sep = ":", to)
  response <- GET(paste0(daily_url, interval, packages),
                  httr::user_agent("cranlogs R package by R-hub"))
  
  stop_for_status(response)
  
  json_data <- fromJSON(content(response, as = "text"), simplifyVector = FALSE,encoding = "UTF-8")
  total_package_downloads <- 0
  freq_package <- c()
  for(x in seq(1,length(json_data[[1]][["downloads"]]),1)){
    freq_package <- c(freq_package, json_data[[1]][["downloads"]][[x]][["downloads"]] )
    total_package_downloads = total_package_downloads + json_data[[1]][["downloads"]][[x]][["downloads"]]
  }
  print("The total number of package downloads in the year was : ")
  print(total_package_downloads)
}
