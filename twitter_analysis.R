library(rtweet)

#use retryonratelimit to get the maximum no of tweets possible
gettweets <- search_tweets(q = "#rstats", retryonratelimit = TRUE)

#filter the data
gettweets <- gettweets[,c("user_id", "status_id","created_at","text","is_quote","is_retweet","quote_count","retweet_count",
                          "reply_count","hashtags","retweet_status_id","retweet_text","retweet_created_at","account_created_at",
                          "profile_image_url","name")]

#store data without considering retweets
noretweets <- search_tweets(q = "#rstats", retryonratelimit = TRUE, include_rts = FALSE)

#filter
noretweets <- noretweets[,c("user_id", "status_id","created_at","text","is_quote","is_retweet","quote_count",
                            "reply_count","hashtags","account_created_at",
                            "profile_image_url","name","location")]

## plot time series of tweets
gettweets %>%
  ts_plot("24 hours") +
  ggplot2::theme_minimal() +
  ggplot2::theme(plot.title = ggplot2::element_text(face = "bold")) +
  ggplot2::labs(
    x = NULL, y = NULL,
    title = "Frequency of #rstats tweets from past 9 days",
    subtitle = "tweet counts aggregated using 24-hour intervals",
    caption = "\nSource: Data collected from Twitter's REST API via rtweet"
  )

#without retweets
noretweets %>%
  ts_plot("24 hours") +
  ggplot2::theme_minimal() +
  ggplot2::theme(plot.title = ggplot2::element_text(face = "bold")) +
  ggplot2::labs(
    x = NULL, y = NULL,
    title = "Frequency of #rstats tweets from past 9 days",
    subtitle = "Tweet counts aggregated using 24-hour intervals(data without retweets)",
    caption = "\nSource: Data collected from Twitter's REST API via rtweet"
  )


#collect data between specified dates
from <- as.Date("2020-02-01")
to <- as.Date("2020-02-11")
interval <- seq.Date(from, to, by =  1)
tweets <- c() 
for (i in seq_along(interval)) {
  get_info <- which(as.Date(gettweets$created_at)==interval[i])
  day <-  gettweets[get_info, ]
  
  tweets <- rbind(tweets, day)
}
print("The tweet information between the specified dates is : ")
summary(tweets)


