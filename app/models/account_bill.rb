class AccountBill < ActiveRecord::Base

  has_many :account_bill_infos, dependent: :destroy
  belongs_to :user
  has_many :adv_content, through: :account_bill

  default_scope { order("created_at DESC") }
  mount_uploader :details, MaterialUploader
  mount_uploader :pay_money_pic, MaterialUploader

  scope :between, ->(d1, d2) {
    where(created_at: Date.parse(d1)...Date.parse(d2).tomorrow)
  }

  scope :start_time_between, ->(d1, d2) {
    where(created_at: Date.parse(d1)...Date.parse(d2))
  }

  scope :happen_time_between, ->(d1, d2) {

  }


  STATE = {"全部" => "0", "账单创建等待对账" => "1", "对账完毕" => "2",  "合作停止欠结余款" => "6", "商务确认-付款完毕" => "7", "财务确认-已付款到帐" => "8", "财务确认-坏账" => "9", "财务确认-账单与到帐金额不一致" => "10"}

  INVOICE_STATE = { "全部" => 4, "需付发票" => 3, "不需发票" => 0, "需付发票- 未付发票" => 1,  "需付发票-已付发票" => 2 }

  #账单状态
   ALL = 0
   UN_CHECKED = 1
   CHECKED = 2

   STOP_WAIT_TO_PAY = 6
   COMMERCE_CONFIRME = 7
   FINANCE_CONFIRME = 8
   BAD_DEBTS = 9
   PAYED_NUM_NOT_RIGHT = 10

  #发票状态
   INVOICE_STATE_ALL = 4

   INVOICE_NO_NEDD = 0
   INVOICE_NEDD_NOT_PAY = 1
   INVOICE_PAYED = 2


  def self.state_sum_balance_range_days(d1, d2, state)
    AccountBill.start_time_between(d1, d2).where(state: state).sum(:balance)
  end
  def self.state_sum_range_days(d1, d2, state)
      AccountBill.start_time_between(d1, d2).where(state: state).count
  end

   def self.state_sum_balance_range_days_invoice(d1, d2, state, *invoice_state)
    AccountBill.start_time_between(d1, d2).where(state: state).where(invoice_state: invoice_state).sum(:balance)
  end
  def self.state_sum_range_days_invoice(d1, d2, state, *invoice_state)
    AccountBill.start_time_between(d1, d2).where(state: state).where(invoice_state: invoice_state).count
  end

  def inoive_state
    []
  end

  def self.user_search_params_permit(user)
    if user.role?(:admin)
      [UN_CHECKED, CHECKED,  STOP_WAIT_TO_PAY, COMMERCE_CONFIRME, FINANCE_CONFIRME, BAD_DEBTS]
    elsif user.role?(:channel_manager)
      [UN_CHECKED, CHECKED,  STOP_WAIT_TO_PAY, COMMERCE_CONFIRME, FINANCE_CONFIRME, BAD_DEBTS]
    elsif user.role?(:finance)
      [CHECKED, STOP_WAIT_TO_PAY, COMMERCE_CONFIRME, FINANCE_CONFIRME, BAD_DEBTS]
    else
      []
    end
  end

  def adv_content_to_label
    str = ""
    self.account_bill_infos.each  do |account_bill_info|
      str << "#{account_bill_info.adv_content.try(:tag)} :"
    end
    str
  end

  def state_to_label
    if AccountBill::STATE.has_value?(self.state)
      "#{AccountBill::STATE.key(self.state)} ----- #{AccountBill::INVOICE_STATE.key(self.invoice_state)}"
    else
      "未知状态"
    end
  end

  def payed?
     true if ([8, 9, 10].include? state.to_i)
  end

  def checked?
    !unchecked?
  end

  def unchecked?
    true if state.to_i == AccountBill::UN_CHECKED
  end

  def confirmed?
    true if state.to_i >= AccountBill::COMMERCE_CONFIRME
  end

  def self.select_lable_to_condition(label)
    case label
      when "全部"then {}
      when "未核对" then {checked: false}
      when "核对" then {checked: true}
      when "已发发票" then {invoice: true}
      when "未发发票" then {invoice: false}
      when "已支付" then {payed: true}
      when "未支付" then {payed: false}
       else {}
      end
  end

  def self.notify_for_finance
    # binding.pry
    AccountBill.where("(state = ? AND expect_to_account_date < ? ) OR invoice_state = ?", COMMERCE_CONFIRME, Date.today, INVOICE_NEDD_NOT_PAY)
  end

  def to_lable
    result_str = "#{self.company}"
    if self.state.to_i == AccountBill::COMMERCE_CONFIRME
      result_str << "需要查看收款"
    end

    if self.invoice_state.to_i == AccountBill::INVOICE_NEDD_NOT_PAY
      result_str << "需要开发票"
    end
    result_str
  end
end
