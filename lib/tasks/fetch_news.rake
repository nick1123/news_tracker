require 'uri'
require 'feedjira'

desc "Fetch news titles from rss feeds"
task :fetch_news => :environment do
  sleep_seconds = 1_200

  while true do
    urls = IO.readlines("lib/flat_files/rss_feeds.txt")
    urls.shuffle.each do |url|
      begin
        next if url.blank?
        url.strip!
        puts "Processing feed: #{url}"
        process_rss_feed(url)
        puts ''
     rescue Exception => e
        puts e
        puts e.backtrace
      end
    end

    puts "Sleeping for #{sleep_seconds} seconds"
    sleep(sleep_seconds)
  end
end

def process_rss_feed(url)
  feed = Feedjira::Feed.fetch_and_parse(url)

  feed.entries.each do |entry|
    add_post(entry.title, entry.url)
  end
end

def add_post(title, url)
  return if url.size > 200
  return if Post.where(url: url).count > 0

  host = URI.parse(url).host.gsub('www.', '')
  post = Post.create(
    title:    title[0..200],
    url:      url,
    host:     host,
    on_date:  Date.today,
  )

  puts "  Added #{title}"
end

