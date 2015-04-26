class Manage::PagesController < ApplicationController
  before_action :set_search_date, only: [:welcome, :dashboard]

  def welcome
    if current_user.role?(:spreader)
      redirect_to manage_charts_channel_view_path
    else
      # Bad example: 3个表 joins 的关联查询造成性能从 0.2 ms 下降到 192 ms
      # @completed_orders = current_user.orders.completed.between(params[:begin], params[:end]).chart_data
      orders = Order.where(application_id: current_user.applications.pluck(:id))
      @completed_orders = orders.completed.between(params[:begin], params[:end]).chart_data
      @total_orders = orders.between(params[:begin], params[:end]).chart_data
    end
  end

  # Admin Dashboard
  def dashboard
    @completed_orders = Order.completed.between(params[:begin], params[:end]).chart_data
    @total_orders = Order.between(params[:begin], params[:end]).chart_data
  end

  def download
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_search_date
      params[:end] = Date.today.strftime('%Y-%m-%d') if params[:end].blank?
      params[:begin] = 7.days.ago(Date.parse(params[:end])).strftime('%Y-%m-%d') if params[:begin].blank?
    end
end
