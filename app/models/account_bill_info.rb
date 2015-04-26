class AccountBillInfo < ActiveRecord::Base
  belongs_to :account_bill
  belongs_to :adv_content
  has_one :adv_detail, through: :adv_content

  default_scope {order ("created_at DESC")}

  validates_presence_of :price, :amount, :start_date, :end_date, :adv_content_id, :account_bill_id
  # validate :
  after_save :update_account_bill_data
  after_destroy :reduce_account_bill_data
  # validate :adv_content_and_start_date_and_account_bill_id

  # def adv_content_and_start_date_and_account_bill_id
  #   bills_info = AccountBillInfo.where(adv_content_id: adv_content_id).order("end_date DESC").first
  #   unless bills_infol.end_date < start_date
  #     false
  #   end
  # end
  def reduce_account_bill_data
    self.account_bill.amount -= self.amount
    self.account_bill.balance -= self.amount * self.price
    self.account_bill.save
  end

  def update_account_bill_data
    i_amount = (self.amount_was ? self.amount_was : 0)
    i_price = (self.price_was ? self.price_was : 0)

    self.account_bill.amount += (self.amount - i_amount).to_f
    self.account_bill.balance += (self.amount * self.price - i_amount * i_price)
    self.account_bill.save
  end


  def self.happpen_time_compute(d1, d2, state, *invoice_state)
    #筛选出符合条件的账单详细
    account =  AccountBillInfo.where.not("account_bill_infos.end_date < ? or account_bill_infos.start_date > ?", Date.parse(d1), Date.parse(d2)).joins(:account_bill).where(account_bills: {state: state})
   account = (invoice_state.size > 0 ? account : account.where("account_bills.invoice_state IN (?)", invoice_state))

     sum_install_count = account.inject(sum = 0) do |sum, item|
      if item.adv_content
        sum += item.adv_content.adv_statistics.where(created_at: Date.parse(d1).midnight()..Date.parse(d2).at_end_of_day()).sum(:install_count)
      else
        sum
      end
     end
     [sum_install_count, account.size]
  end

  scope :between, ->(d1, d2) {
    ids = i_between(d1, d2)
    where.not(id: ids)
  }


  scope :i_between, ->(d1, d2) {
    where("end_date <= ? or start_date >= ?", Date.parse(d1), Date.parse(d2).tomorrow).pluck(:id)
  }

  def total_balance
    (self.price.to_f  * self.amount).round(2)
  end
end
