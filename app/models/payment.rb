# encoding: utf-8
class Payment < ActiveRecord::Base
  # extends ...................................................................
  # includes ..................................................................
  # relationships .............................................................
  belongs_to :user
  # validations ...............................................................
  validates_numericality_of :amount,
    only_integer: true,
    less_than_or_equal_to: ->(user) { user.amount },
    greater_than_or_equal_to: 100,
    message: "提现金额需是大于 100 元并且小于您帐户余额之间的整数"


  # callbacks .................................................................
  # scopes ....................................................................
  scope :working, -> { where(:state => 0..2) }

  # additional config .........................................................
  STATES = [["审核中", 0], ["处理中", 1], ["转账中", 2], ["已结算", 3], ["作废", 4]]
  before_create :set_default_value
  after_create :reduce_amount

  # class methods .............................................................
  # public instance methods ...................................................
  def payment_amount
    amount - tax
  end

  # protected instance methods ................................................
  # private instance methods ..................................................
  private

  def reduce_amount
    user.reduce_amount(amount)
  end

  def generate_transaction_number
    # If 0 is given or an argument is not given, ::random_number returns a float: 0.0 <= ::random_number < 1.0.
    # Example: SecureRandom.random_number #=> 0.596506046187744
    number = SecureRandom.random_number.to_s
    # number.split(".").last.split(/(?<=\G.{4})(?!$)/).join("-")
    number[2, 4] + "-" + number[6, 4] + "-" + number[10, 4]
  end

  def set_default_value
    self.transaction_number ||= generate_transaction_number
    self.state ||= 0
    self.tax ||= self.amount * 0.055
  end
end
