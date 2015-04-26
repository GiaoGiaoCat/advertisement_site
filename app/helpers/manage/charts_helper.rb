# encoding: utf-8
module Manage::ChartsHelper
  def sum_count(array)
    array.nil? ? 0 : array.inject(0) { |sum, o| sum + o[:count] }
  end

  def shipped_orders_rate_by_channel(channel, begin_date = nil, end_date = nil)
    orders = calculate_shipped_orders_by_channel(channel, begin_date, end_date)
    devices = calculate_device_by_channel_for_admin(channel, begin_date, end_date)
    number_to_percentage (orders / devices.to_f).round(6) * 100
  rescue
    '无数据'
  end

  def recovery_by_channel(channel, price, begin_date = nil, end_date = nil)
    orders = calculate_shipped_orders_by_channel(channel, begin_date, end_date)
    devices = calculate_device_by_channel_for_spreader(channel, begin_date, end_date)

    ((orders * 60) / (price * devices)).round(2)
  rescue
    '无数据'
  end

  # 根据规则计算某一渠道激活设备总数
  def calculate_device_by_channel_with_ratio(channel, ratio, begin_date = nil, end_date = nil)
    begin_date ||= 6.days.ago(Date.today).to_s
    end_date ||= Date.today.to_s

    Device.by_channel_name(channel.name).between(begin_date, end_date)
      .chart_data(ratio).inject(0) { |sum, hash| sum + hash[:count] }
  end

  # spreader看激活用户，扣量
  def calculate_device_by_channel_for_spreader(channel, begin_date = nil, end_date = nil)
    calculate_device_by_channel_with_ratio(
      channel,
      # channel.user.ratio(channel.name),
      channel.ratio_settings_for_user(channel.user),
      begin_date,
      end_date
    )
  end

  # 管理员查看激活用户，不扣量
  def calculate_device_by_channel_for_admin(channel, begin_date = nil, end_date = nil)
    calculate_device_by_channel_with_ratio(
      channel,
      # current_user.ratio(channel.name),
      channel.ratio_settings_for_user(current_user),
      begin_date,
      end_date
    )
  end

  # 计算某一渠道发货订单的总数
  def calculate_shipped_orders_by_channel(channel, begin_date = nil, end_date = nil)
    begin_date ||= 6.days.ago(Date.today).to_s
    end_date ||= Date.today.to_s

    orders = Order.by_channel_name(channel.name).between(begin_date, end_date).shipped.chart_data

    sum_count(orders)
  end

  # 计算某一渠道的收入
  def calculate_revenues_by_channel(channel, begin_date, end_date)
    orders = calculate_shipped_orders_by_channel(channel, begin_date, end_date)
  end

  # 计算某一渠道的支出
  def calculate_expenses_by_channel(channel, begin_date, end_date)
    devices = calculate_device_by_channel_for_spreader(channel, begin_date, end_date)
  end

  def show_channel_rules(rules)
    return unless rules
    content_tag :ul do
      rules.map { |rule| concat content_tag(:li, "#{rule.activate_at} #{rule.ratio}") }
    end
    # rules.map { |rule| rule.activate_at.to_s concat content_tag(:span, rule.ratio) }.join(content_tag(:br))
  end

  def highliht_recovery(recovery)
    class_name = "badge "
    class_name += recovery.to_f > 1 ? "badge-success" : "badge-warning"
    content_tag(:span, recovery, class: class_name)
  end

end
