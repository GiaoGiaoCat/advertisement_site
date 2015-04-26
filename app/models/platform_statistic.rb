class PlatformStatistic < ActiveRecord::Base
  belongs_to :platform
  belongs_to :adv_content
  validates :platform_id, presence: true
  validates :report_date, presence: true
  validates :install_count, presence: true
  validates :adv_content_id, presence: true

  scope :between, ->(d1, d2) {
    where(report_date: Date.parse(d1).midnight..Date.parse(d2).end_of_day)
  }

  scope :platform_statistics_by_adv_content, ->(adv_content_id){
    where(adv_content_id: adv_content_id)
  }
end
