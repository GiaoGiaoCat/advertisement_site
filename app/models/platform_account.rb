class PlatformAccount < ActiveRecord::Base
  has_many :platform_balanceios
  belongs_to :platform
  validates :account_name, presence: true
  validates :platform_id, presence: true
  scope :between, ->(d1, d2) {
    where(created_at: Date.parse(d1).midnight..Date.parse(d2).end_of_day)
  }

  def balance_total_by_time(d1, d2)
    self.platform_balanceios.between(d1, d2).sum(:money)
  end
end
