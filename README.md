# rcEXP
The scripts to perform R community exploration

The exploration has been performed at three platforms,namely

CRAN exploration(Current status):

The data of all the packages of CRAN is stored in a dataframe and the data is tidied by removing the rows without a package name or a date(The filtering criteria can be modified according to the requirements).

The daily,monthly,yearly downloads and top50 downloaded packages can be easily obtained.The results can be visualized using frequnecy plots.

The popular packages(assuming it to be same as the trending packages), popular authors, most active authors can also be obtained.

A word cloud of the most common words used in the description of the packages can also be obtained.
A word cloud obtained by scraping a sample of 1000 packages can be seen below :


![img](https://raw.githubusercontent.com/acharaakshit/rcEXP/master/word_cloud.png)

A dependency network graph can also be obtained for the packages.

Twitter exploration(Current Status):
The api can be used to get all the tweets which are using #rstats

and

Github exploration: 
