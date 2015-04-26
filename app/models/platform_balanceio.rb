class PlatformBalanceio < ActiveRecord::Base
  belongs_to :platform_account
  belongs_to :adv_content
  validates :platform_account_id, presence: true
  validates :money, presence: true
  validates :adv_content_id, presence: true
  validates :report_date, presence: true
  validates_uniqueness_of :adv_content_id, scope: [:report_date, :platform_account_id]

  default_scope { order("report_date DESC") }

  scope :between, ->(d1, d2) {
    where(report_date: Date.parse(d1).midnight..Date.parse(d2).end_of_day)
  }
end
