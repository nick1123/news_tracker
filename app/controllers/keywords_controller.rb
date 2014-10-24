class KeywordsController < ApplicationController
  def index
    @title = "Keywords"
    ordering = "occurences DESC, phrase ASC"
    min_occurences = 2
    @week = {}
    @week["Last 24 Hours"] = Keyword.where(created_at: (24.hours.ago..Time.now)).where("occurences >= ?", min_occurences).order(ordering)
    (1..6).each do |days_back|
      day = Date.current - days_back
      day_display = day.strftime("%A %B %-d, %Y")
      keywords = Keyword.where(on_date: day).where("occurences >= ?", min_occurences).order(ordering)
      @week[day_display] = keywords if keywords.count > 0
    end
  end
end
