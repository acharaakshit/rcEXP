library(jsonlite)
library(httr)

#store the data related to the packages
pkg_info <- tools::CRAN_package_db()

#clean the data

#remove the unnecessary columns
pkg_info <- pkg_info[,c("Package","Version", "Depends", "Imports","Suggests","Author","Authors@R","BugReports",
                     "Date", "Description","Maintainer","Title","URL","Published","Reverse depends", "Reverse imports")]

length(which(is.na(pkg_info$Package)))
#remove the columns without name
if(length(which(is.na(pkg_info$Package)))){
  pkg_info <- pkg_info[-which(is.na(pkg_info$Package)),]
}


#find the most popular packages
popular_url <- "https://cranlogs.r-pkg.org/trending"
response <- GET(popular_url, httr::user_agent("cranlogs R by R-hub"))
stop_for_status(response)
popular_pkgs <- fromJSON(content(response, as = "text"), simplifyDataFrame = TRUE)
print("The most popular packages are : ")
print(popular_pkgs$package)

#Find the most frequently updated packages
library(anytime)
parent_url <- "http://crandb.r-pkg.org/"
packages <- pkg_info[1:10,]$Package
#to count the number of frequent updations, just checking the first 10 packages here
count <- 0
frequently_updated_pkgs <- c()
for(x in seq(1,length(packages),1)){
  count <- 0
  package <- packages[x]
  URL <- paste0(parent_url,package,"/all")
  if(length(fromJSON(URL)$versions)>1){
    for (y in seq(2,length(fromJSON(URL)$versions),1)) {
    
      initial <- fromJSON(URL)$versions[[y]]$Date
      final <- fromJSON(URL)$versions[[y-1]]$Date
      no_of_updates <- (as.numeric(anydate(final)) - as.numeric(anydate(initial)))/30 # months
      if(is.numeric(no_of_updates) & !is.na(no_of_updates)){
        if(no_of_updates <= 3){
          count <- count+1
        }
      }
    }
  }
  if(count > 0){
    frequently_updated_pkgs <- c(frequently_updated_pkgs, packages[x])
  }
}
print("The frequnetly updated packages are : ")
print(frequently_updated_pkgs)


#find the newly released R packages 
#assuming that a package was released in last 6 months, it was new
current_date <- Sys.Date() 
check_till_date <- seq(as.Date(current_date), length = 2, by = "-6 months")[2]
new_pkg_info <- with(pkg_info, pkg_info[(Date >= check_till_date), ])
#remove the columns without name
if(length(which(is.na(new_pkg_info$Package)))){
  new_pkg_info <- new_pkg_info[-which(is.na(new_pkg_info$Package)),]
}
print("The new release packages are : ")
print(new_pkg_info$Package)

#find the frequency of newly installed packages for each month in last 6 months
for (x in seq(1,6,1)) {
  by_str <- paste0("-",as.character(0)," months")
  by_str_1 <- paste0("-",as.character(1)," months")
  initial_date <- seq(as.Date(current_date), length = 2, by = by_str)[2]
  final_date <- seq(as.Date(current_date), length = 2, by = by_str_1)[2]
  month_pkg_info <- with(pkg_info, pkg_info[(Date >= initial_date & Date <= final_date), ])
  
}


#make a word cloud for first 100 packages in the dataframe
install.packages("tm")  # for text mining
install.packages("SnowballC") # for text stemming
install.packages("wordcloud") # word-cloud generator 
install.packages("RColorBrewer") # color palettes
# Load
library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")
words <- Corpus(VectorSource(pkg_info[1:100,]$Description))
inspect(words)
toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
words <- tm_map(words, toSpace, "/")
words <- tm_map(words, toSpace, "@")
words <- tm_map(words, toSpace, "\\|")

# Convert the text to lower case
words <- tm_map(words, content_transformer(tolower))
# Remove numbers
words <- tm_map(words, removeNumbers)
# Remove english common stopwords
words <- tm_map(words, removeWords, stopwords("english"))
# Remove your own stop word
# specify your stopwords as a character vector
words <- tm_map(words, removeWords, c("blabla1", "blabla2")) 
# Remove punctuations
words <- tm_map(words, removePunctuation)
# Eliminate extra white spaces
words <- tm_map(words, stripWhitespace)
# Text stemming
# docs <- tm_map(docs, stemDocument)

dtm <- TermDocumentMatrix(words)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)

set.seed(1234)
wordcloud(words = d$word, freq = d$freq, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))


#make a network of dependencies,the network here has been obtained for first 1000 packages only
library(pkggraph)
library(stringr)
graph_mat <- matrix(0L, nrow = 1000, ncol = 1000)
colnames(graph_mat) <- pkg_info[1:1000,]$Package
rownames(graph_mat) <- pkg_info[1:1000,]$Package
tot_dep <- c()

for (x  in seq(1,1000,1)) {
  dependencies <- pkg_info[x,]$Imports
  dependencies  <- gsub("[^A-Za-z///' ]","'" , dependencies ,ignore.case = TRUE)
  dependencies <- gsub("'","" , dependencies ,ignore.case = TRUE)
  dependencies <- strsplit(dependencies," ")
  dependencies <- dependencies[[1]][-which(dependencies[[1]] == "")]
  tot_dep <- c(tot_dep, dependencies)
  if(length(dependencies)){
    print("ok")
  for (y in seq(1,length(dependencies),1)) {
    print(length(dependencies))#which(colnames(graph_mat) == dependencies[x]))
    graph_mat[x,which(colnames(graph_mat) == dependencies[y])] = 1  
  }
  }
}

library(igraph)
graph = graph.adjacency(graph_mat, mode = "directed")
isolated_vertices = which(degree(graph)==0)
graph2 = delete.vertices(graph, isolated_vertices)
plot(graph2,layout=layout_with_fr, vertex.size=5,
     vertex.label.dist=0.15, vertex.color="red", edge.arrow.size=0.15)




