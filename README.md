## Simple News Keyword Tracker

Run `rake fetch_news` every hour to pull in the latest news items and
extract keywords.

You can run `rake prune_old_keywords` to remove old keyword with a low
occurance rate for previous days.

Run the server and the root route will show the Keywords for the last
few days
