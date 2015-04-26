class AdvStatistic < ActiveRecord::Base
  # extends ...................................................................
  # includes ..................................................................
  # relationships .............................................................
  belongs_to :application
  belongs_to :adv_content
  belongs_to :platform
  # validations ...............................................................
  # callbacks .................................................................
  # scopes ....................................................................
  scope :by_app, ->(app_id) { where(application_id: app_id) }
  scope :by_advertisement, ->(advertisement_id) {
    where(adv_content_id: advertisement_id)
  }
  scope :today, -> {
    where(created_at: Date.today.midnight..Date.today.end_of_day)
  }
  scope :by_days, ->(n) {
    where(created_at: n.days.ago(Date.today).midnight..Date.today.end_of_day)
  }
  scope :yesterday, -> {
    where(created_at: 1.days.ago(Date.today).midnight..1.days.ago(Date.today).end_of_day)
  }
  scope :between, ->(d1, d2) {
    where(created_at: Date.parse(d1).midnight..Date.parse(d2).end_of_day)
  }

  scope :adv_content_reports, ->(adv_content_id) {
    where(adv_content_id: adv_content_id)
  }
  scope :application_reports, ->(application_id) {
    where(application_id: application_id)
  }

  scope :by_day, -> (day){
    where(created_at: day.midnight..day.end_of_day)
  }
  # additional config (i.e. accepts_nested_attribute_for etc...) ..............
  # class methods .............................................................
  def self.chart_data(column)
    result = []
    select("`adv_statistics`.`created_at`, `adv_statistics`.`#{column}` AS count").group("DATE_FORMAT(`adv_statistics`.`created_at`,'%Y-%m-%d')").each do |row|
      result << { day: row.created_at.strftime('%Y-%m-%d'), count: row.count }
    end
    result
  end

  # public instance methods ...................................................
  # protected instance methods ................................................
  # private instance methods ..................................................
end
