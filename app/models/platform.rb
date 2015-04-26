class Platform < ActiveRecord::Base
  has_many :platform_accounts
  has_many :platform_balanceios, through: :platform_accounts
  has_many :platform_statistics
  validates :name, presence: true
  validates :adv_content_ids, presence: true
  serialize :adv_content_ids

  default_scope { order("created_at DESC") }

  scope :between, ->(d1, d2) {
    where(created_at: Date.parse(d1).midnight..Date.parse(d2).end_of_day)
  }
  def adv_contents_to_label
    adv_contents = AdvContent.where(id: adv_content_ids)
    adv_contents.inject("") {|label, item| label << "#{item.tag};"}
  end

  def accounts_to_label
    self.platform_accounts.inject("") {|label, account| label << "#{account.account_name}; "}
  end

  def accounts_balances_with_date_to_label(d1, d2, adv_content_id)
    arry = ""
    sum = 0
    self.platform_accounts.each do |account|
      account_total = account.platform_balanceios.between(d1, d2).where(adv_content_id: adv_content_id).sum(:money)
      arry << "#{account.account_name}: #{account_total}"
      sum += account_total
    end
    return [arry, sum]
  end

  def accounts_balances_to_label
    self.platform_accounts.inject("") {|label, account| label << "#{account.account_name}: #{account.platform_balanceios.sum(:money)}"}
  end

  def balance_total_to_lable(d1, d2)
    self.platform_balanceios.between(d1, d2).sum(:money)
  end

  # def platform_statistics(addd)
  def adv_content_ids
    self[:adv_content_ids].map { |id| id.to_i } if self[:adv_content_ids]
  end

  def self.platforms_by_adv_content_id(adv_content_id)
    Platform.all.select {|platform| platform.adv_content_ids.include? adv_content_id}
  end

  def platform_statistics_by_adv_content_id_and_time(adv_content_id, d1, d2)
    self.platform_statistics.platform_statistics_by_adv_content(adv_content_id).between(d1, d2).sum(:install_count)
  end

  def platform_accounts_by_time(d1, d2, adv_content_id)
    self.platform_balanceios.between(d1, d2).where(adv_content_id: adv_content_id).sum(:money)
  end
end
