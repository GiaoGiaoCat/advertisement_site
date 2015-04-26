# encoding: utf-8
class Order < ActiveRecord::Base
  # extends ...................................................................
  # includes ..................................................................
  include ConversionRatio
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
  belongs_to :user
  belongs_to :application
  belongs_to :device, :primary_key => "device_id"
  # validations ...............................................................
  # callbacks .................................................................
  # scopes ....................................................................
  # 过滤掉虚拟订单，后台创建订单和没有设备号的订单
  default_scope -> {
    where("orders.device_id <> ?", 'Simulator_00000001')
      .where("orders.device_id IS NOT NULL")
      .where("orders.device_id <> ''")
  }
  scope :shipped, -> { where(:state => Order::SHIPPED_STATES) }
  scope :completed, -> { where(:state => "客户签收，订单完成") }
  scope :between, ->(d1, d2) {
    where(:created_at => Date.parse(d1)...Date.parse(d2).tomorrow)
  }
  scope :by_channel_name, ->(channel) {
    joins(:device).where("devices.channel_id = ?", channel)
  }
  # additional config ..................................................
  # STATES = ["订单已下，等待确认",
  #           "正在处理", "等待配货", "正在配货",
  #           "已发货，准备收货",
  #           "客户放弃，订单取消", "无法联系客户，订单取消", "有拒签记录，订单取消", "非本人下单，订单取消", "重复订单，订单取消",
  #           "客户签收，订单完成", "客户拒签，原件返回"]
  SHIPPED_STATES = [
    "等待配货", "正在配货", "已发货，准备收货", "客户拒签，原件返回", "客户签收，订单完成"
  ]
  # class methods .............................................................
  def self.chart_data(ratio_settings = [])
    result = []
    select("`orders`.`created_at`, COUNT(DISTINCT `orders`.`device_id`) as total_num, SUM(item_total) as total_price").group("DATE_FORMAT(`orders`.`created_at`,'%Y-%m-%d')").each do |row|
      ratio = get_ratio(ratio_settings, row.created_at)
      result << { day: row.created_at.strftime('%Y-%m-%d'), count: (row.total_num * ratio).round, total: row.total_price.to_f/10 }
    end
    result
  end
  # public instance methods ...................................................
  # protected instance methods ................................................
  # private instance methods ..................................................

end
