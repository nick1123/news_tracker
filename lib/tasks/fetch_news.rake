require 'uri'
require 'feedjira'

desc "prune old keywords"
task :prune_old_keywords => :environment do
  Keyword.where("on_date < ?", Date.current).where("occurences <= 2").delete_all
end

desc "Fetch news titles from rss feeds"
task :fetch_news => :environment do
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

  Keyword.where(on_date: Date.current).order("occurences DESC").limit(10).each {|k| puts "#{k.occurences}\t#{k.phrase}"}
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
  phrases = extract_keywords(title)

  phrases.each do |phrase|
    keyword = Keyword.where(phrase: phrase).where(on_date: Date.current).first
    if keyword.present?
      keyword.occurences += 1
      keyword.save
    else
      Keyword.create(phrase: phrase)
    end
  end

  puts phrases.inspect

  puts ""
end

def extract_keywords(title)
  # Modify tile
  title = title.downcase.gsub(/[\u2018\u2019]/, "'").gsub(/[\u201C\u201D]/, '')

  ['(', ')', '[', ']', "'s ", ' - '].each do |chars|
    title.gsub!(chars, ' ')
  end

  title = title.gsub(/\s+/, ' ').strip

  # Split title into words
  words = title.split(/\s+/)

  # Remove leading & trailing chars from each word
  [':', '?', ',', "'"].each do |char|
    words = words.map do |word|
      word.chomp(char).reverse.chomp(char).reverse
    end
  end

  n2 = ngrams(words, 2)
  words.concat(n2)
  return words
end

def self.ngrams(words, n)
  words.each_cons(n).to_a.map {|a| a.join(' ')}
end
