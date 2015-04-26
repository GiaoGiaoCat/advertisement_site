class User < ActiveRecord::Base
  # extends ...................................................................
  # includes ..................................................................
  include UserRelationship
  has_many :adv_contents
  has_many :account_bills
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
  # has_many :applications, :class_name => "Manage::Application"
  # validations ...............................................................
  # callbacks .................................................................
  # scopes ....................................................................
  scope :staff_members, -> { where(role: User::ROLES) }
  scope :channel_manager, -> { where(role: "channel_manager") }

  # additional config ..................................................
  # additional config ..................................................
  ROLES = %w[developer spreader channel_manager secretary finance]
  USERROLES = {"developer" => %w[spreader], "admin" => %w[developer spreader channel_manager secretary],
  "spreader" => %w[spreader],
  "channel_manager" => %w[spreader] }

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_initialize :set_default_role, if: 'new_record?'
  # class methods .............................................................
  # public instance methods ...................................................
  def role?(role)
    self.role == role.to_s
  end

  def can_withdraw_cash?
    amount >= 100 && payments.working.size.zero?
  end

  def amount
    self.profile.try(:amount) || 0
  end

  def reduce_amount(amount)
    self.profile.update_attribute(:amount, self.amount - amount)
  end

  # protected instance methods ................................................
  # private instance methods ..................................................
  private
  def set_default_role
    self.role ||= "developer"
  end
end
