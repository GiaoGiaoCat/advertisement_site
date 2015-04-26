class Channel < ActiveRecord::Base
  # extends ...................................................................
  # includes ..................................................................
  # relationships .............................................................
  belongs_to :spreader, foreign_key: :user_id
  belongs_to :manager, class_name: 'ChannelManager', foreign_key: :manager_id
  # remove belongs to user laster, and move the logic to spreader model.
  belongs_to :user, foreign_key: :user_id
  has_many :rules
  has_many :applications, -> { uniq }, through: :rules
  # validations ...............................................................
  validates :name, :presence => true
  # callbacks .................................................................
  after_initialize :set_basic_ratio_settings
  # scopes ....................................................................
  scope :available, -> { where(enabled: true) }
  # additional config (i.e. accepts_nested_attribute_for etc...) ..............
  encrypted_id key: 'u6mMccnwbi2qPQWp'

  delegate :name, to: :spreader, prefix: true, allow_nil: true

  attr_reader :ratio_settings

  LEVELS = 1...4
  # class methods .............................................................
  # public instance methods ...................................................
  def ratio_settings=(new_settings)
    @ratio_settings << new_settings
  end

  def auto_ratio_activate_at
    self[:auto_ratio_activate_at].try(:to_date)
  end

  def ratio_settings_for_user(user)
    case user.role.to_sym
    when :admin
      ratio_settings_for_admin
    when :channel_manager
      ratio_settings_for_channel_manager
    else
      ratio_settings_for_spreader
    end
  end

  def ratio_settings_for_admin
    ratio_settings
  end
  alias_method :ratio_settings_for_channel_manager, :ratio_settings_for_admin

  def ratio_settings_for_spreader
    ratio_settings = rules.reformat
  end

  def can_generate_auto_ratio_setting?
    rules.where(
      name: 'Auto Rule', activate_at: Date.yesterday.beginning_of_day
    ).count.zero?
  end

  def generate_auto_ratio_setting
    rule = calculate_auto_ratio
    rules.create(name: 'Auto Rule', ratio: rule[0].to_f, activate_at: rule[1])
  end

  def calculate_auto_ratio
    devices =
      Device.by_channel_name(name).chart_data([[1, "2010-10-10"]])
        .inject(0) { |sum, hash| sum + hash[:count] }

    calculate_auto_ratio_by_device_total(devices)
  end

  # 根据注册用户的数量，采用不同的计算公式
  def calculate_auto_ratio_by_device_total(devices)
    date = Date.yesterday.to_date

    if devices < 400
      calculate_auto_ratio_low(devices, date)
    elsif devices >= 400 and devices < 1000
      calculate_auto_ratio_normal(devices, date)
    else
      calculate_auto_ratio_high(devices, date)
    end
  end

  # rules 排序应该以日期顺序排列
  def last_k
    rules.order("activate_at DESC").first.try(:ratio) || 0.4
  end

  def calculate_auto_ratio_low(devices, date)
    [0.4, date]
  end

  def calculate_auto_ratio_normal(devices, date)
    orders = Order.by_channel_name(name).shipped.chart_data
    shipped_orders_total = orders.inject(0) { |sum, o| sum + o[:count] }

    r = calculate_recovery(shipped_orders_total, devices, last_k)
    k = calculate_k(shipped_orders_total, devices, 0.8, r)

    [k, date]
  end

  # 这里的参数 devices 没有用，统一参数名只是为了将来方便重构方法。
  def calculate_auto_ratio_high(devices, date)
    begin_date = 6.days.ago(Date.today).to_date.to_s
    end_date = Date.today.to_date.to_s
    # 订单数目改成最近7天的
    orders = Order.by_channel_name(name).between(begin_date, end_date).shipped.chart_data
    shipped_orders_total = orders.inject(0) { |sum, o| sum + o[:count] }

    # devices 改成最近7天的
    devices =
      Device.by_channel_name(name).between(begin_date, end_date)
        .chart_data([[1, "2010-10-10"]]).inject(0) { |sum, hash| sum + hash[:count] }

    r = calculate_recovery(shipped_orders_total, devices, last_k)
    k = calculate_k(shipped_orders_total, devices, 1, r)

    [k, date]
  end
  # protected instance methods ................................................
  # private instance methods ..................................................
  private

    def set_basic_ratio_settings
      @ratio_settings = [[1, "2010-10-10"]]
    end

    def calculate_recovery(orders_total, devices, ratio)
      r = (orders_total * 60) / (price * devices * ratio)
      # 重新启动渠道的时候，有可能造成该渠道曾经推广用户超过1000，但近7天无数据
      r = 1 if r.nan?
      r
    end

    def calculate_k(orders_total, devices, ratio, recovery)
      if recovery >= ratio
        last_k
      else
        calculate_recovery(orders_total, devices, ratio)
      end
    end
end
