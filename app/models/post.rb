class Post < ActiveRecord::Base
  before_create :add_on_date

  private

  def add_on_date
    self.on_date = Date.current
  end
end
