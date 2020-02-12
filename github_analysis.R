#R script for github analysis

library(httr)
#to store the information of all the repositories
repo_info <- c()
#to store the package names
repo_names <- c()
#to store the release dates
repo_dates <- c()

#search R repositories on github
#The number of searches that can be retrieved from github api are limited therefore 
#page_no moves from page 1 to page 100 at present and can be changed later
#page_no means the page number of search results here.
for(page_no in seq(1,100,1)){

#set the url path for searching r repositories on github  
path <- paste0("search/repositories?q=+language:R&page=",as.character(page_no),"&per_page=100&sort=stars&order=desc")
url <- paste0("https://api.github.com/",path)
response <- tryCatch(
                    {httr::GET(url)}
                    ,
                    error = function(e){
                      print("The error is :")
                      stop(e)
                    }
                    )
json_data <- jsonlite::fromJSON(httr::content(response, as ="text"), simplifyVector = FALSE)

#if json_data doesn't have any content, then stop and print the error
#maybe the number of results that can be extracted are limited
if(length(json_data)!=3){
  print("the data couldn't be retrieved because")
  print(json_data$message)
  break
}

repo_page_info <- structure(
          list(
            content = json_data,
            path = url,
            response = response
          ),
      class = "github_api"
  )
repo_info <- cbind(repo_info, repo_page_info)


for (x in seq(1,length(repo_page_info$content$items),1)) {

  repo_names <- c(repo_names,repo_page_info$content$items[[x]]$name)  
  repo_dates <- c(repo_dates,repo_page_info$content$items[[x]]$created_at)
}

repos <- cbind(repo_names,repo_dates)
}

print("The most starred repositories are : ")
print(repos)


print("The top 10 starred repositories are : ")
print(repo_names[1:10])

