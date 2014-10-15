class Keyword < ActiveRecord::Base
  before_create :add_on_date, :add_word_count

  private

  def add_on_date
    self.on_date = Date.current
  end

  def add_word_count
    self.word_count = self.phrase.split(/\s+/).size
  end
end
