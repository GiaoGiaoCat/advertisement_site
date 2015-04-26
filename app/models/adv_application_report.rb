class AdvApplicationReport < ActiveRecord::Base
  # extends ...................................................................
  # includes ..................................................................
  # relationships .............................................................
  belongs_to :application
  # validations ...............................................................
  # callbacks .................................................................
  # scopes ....................................................................
  default_scope { order("created_at DESC") }
  scope :today, -> {
    where(created_at: Date.today.midnight..Date.today.end_of_day)
  }
  scope :between, ->(d1, d2) {
    where(created_at: Date.parse(d1).midnight..Date.parse(d2).end_of_day)
  }
  scope :yesterday, -> {
    where(created_at: 1.days.ago(Date.today).midnight..1.days.ago(Date.today).end_of_day)
  }
  # additional config (i.e. accepts_nested_attribute_for etc...) ..............
  # class methods .............................................................
  # public instance methods ...................................................
  # protected instance methods ................................................
  # private instance methods ..................................................
end
