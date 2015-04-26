class AdvAdvertiserReport < ActiveRecord::Base
  # extends ...................................................................
  # includes ..................................................................
  # relationships .............................................................
  belongs_to :adv_content
  # validations ...............................................................
  validates_uniqueness_of :adv_content_id, scope: :report_date

  validates_numericality_of :count, greater_than_or_equal_to: 0
  validates :report_date, presence: true
  # callbacks .................................................................
  # scopes ....................................................................
  default_scope { order("report_date DESC") }
  scope :between, ->(d1, d2) {
    where(report_date: Date.parse(d1)...Date.parse(d2).tomorrow)
  }
  scope :by_days, ->(n) {
    where(report_date: n.days.ago(Date.today)..Date.today)
  }
  # additional config (i.e. accepts_nested_attribute_for etc...) ..............
  # class methods .............................................................
  def self.chart_data(column)
    result = []
    select("report_date, #{column} AS count").each do |row|
      result << { day: row.report_date.strftime('%Y-%m-%d'), count: row.count }
    end
    result
  end

  # public instance methods ...................................................
  # protected instance methods ................................................
  # private instance methods ..................................................
end