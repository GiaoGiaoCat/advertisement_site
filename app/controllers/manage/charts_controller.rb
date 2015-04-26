class Manage::ChartsController < ApplicationController
  before_action :set_search_date

  def daily_view
    if params[:app]
      app = Application.find(params[:app])
      @completed_orders = app.orders.completed.between(params[:begin], params[:end]).chart_data
      @total_orders = app.orders.between(params[:begin], params[:end]).chart_data
    end
  end

  def income_view
    if params[:begin] && params[:end]
      # Notice: chart_data method return a array.
      @orders_array = current_user.orders.completed.between(params[:begin], params[:end]).chart_data
      # Use paginate_array helper method to paginate an array object using Kaminari
      @orders_array = Kaminari.paginate_array(@orders_array).page(params[:page])
    end
  end


  # TODO: 这里需要添加权限验证，用户只能看自己渠道下的数据
  # spreader 查看渠道统计概要
  def channel_view
    @channels = current_user.channels.available

    if params[:channel_id]
      channel = Channel.find(params[:channel_id])
      receive_data(channel, channel.user) if channel
    end
  end

  # admin and channel_manager 查看渠道统计概要
  def channel_data
    @channels =
      if current_user.role?(:admin)
        Channel.available
      elsif current_user.role?(:channel_manager)
        Channel.where(manager_id: current_user.id).available
      end

    if params[:level].present?
      @channels = @channels.where(level: params[:level])
    end
  end

  # TODO: 这里需要添加权限验证，只有 admin and channel_manager 能才可访问此 action
  def channel_data_detail
    @channel = Channel.find(params[:channel_id])
    receive_data(@channel, @channel.user)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_search_date
      if params[:commit]
        params[:end] = Date.today.strftime('%Y-%m-%d') if params[:end].blank?

        # spreader 只能查看前一天的数据
        if current_user.role?(:spreader) && Date.parse(params[:end]) >= Date.today
          params[:end] = Date.yesterday.strftime('%Y-%m-%d')
        end

        if params[:begin].blank?
          params[:begin] =
            30.days.ago(Date.parse(params[:end])).strftime('%Y-%m-%d')
        end
      end
    end

    def receive_data(channel, user = nil)
      end_day_str =
       if Date.parse(params[:end]) >= Date.today.prev_day.prev_day  && (!current_user.role? (:admin)) && (!current_user.role?(:channel_manager))
            if Time.now() <  Time.now.middle_of_day()
              flash[:notice] = "数据整理中，昨日数据中午后查看,数据为前日数据"
              Date.today.prev_day.prev_day.to_s
            else
              flash[:notice] = "数据为昨日数据"
              Date.today.prev_day.to_s
            end
        else
         params[:end]
        end
      devices =
        Device.by_channel_name(channel.name).between(params[:begin],end_day_str)
      user ||= current_user
      @devices_for_spreader =
        devices.chart_data(channel.ratio_settings_for_user(user))
      # show order and device detail logs for admin or channel_manager.
      receive_data_for_admin(channel, devices) if current_user.role?(:admin) || current_user.role?(:channel_manager)
    end

    def receive_data_for_admin(channel, devices)
      @devices =
        devices.chart_data(channel.ratio_settings_for_user(current_user))

      orders = Order.by_channel_name(channel.name).between(params[:begin], params[:end])
      @orders = orders.chart_data
      @completed_orders = orders.completed.chart_data
      @shipped_orders = orders.shipped.chart_data
    end
end
