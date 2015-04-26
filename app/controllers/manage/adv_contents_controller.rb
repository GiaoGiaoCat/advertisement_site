# encoding: utf-8
class Manage::AdvContentsController < ApplicationController
  before_action :set_search_date_yesterday, only: [:applications, :charts, :index, :trash]
  before_action :set_search_state, only: [:index]
  before_action :set_adv_content, only: [:edit, :destroy, :update, :show, :applications, :active_content, :advtatics, :plant, :settings, :put_trash, :state_operate]
  authorize_resource
  PAGESIZE = 50
  # GET /manage/adv_content
  def index
    i_adv_contents = if params[:application_id].blank?
      adv_contents = AdvContent.order("created_at DESC")
      params[:search].present? ? adv_contents.where("tag LIKE ?", "%#{params[:search].strip}%") : adv_contents
    else
      Application.find_by_id(params[:application_id]).not_in_trash.get_adv_contents
    end
    @adv_contents = i_adv_contents.in_state(params[:state])

    if params[:ids].present? &&  params[:ids].size > 0
      @adv_contents = @adv_contents.where(id: params[:ids])
    end

    if (params[:state] != "on" && !current_user.role?(:admin))
      @adv_contents = @adv_contents.where("user_id = ?", current_user.id)
    end

    sign = false
    sign = true unless params[:is_base_on_cp_report_date].nil?
    compute_number( @adv_contents, sign)
    if (!current_user.role?(:admin)) && params[:format] == "xlsx"
      flash[:notice] = "没有权限，请联系管理员"
      redirect_to :back
      return
    end
    respond_to do |format|
      format.html
      render_result = download_xlsx_name(@adv_contents) if params[:format] == "xlsx"
      format.xlsx{render xlsx: "#{render_result[:template_file]}", filename:  "#{render_result[:filename]}"}
    end
  end

  def state_operate
    case params[:state]
      when "on"
        @adv_content.update_columns(deleted: false, trash: false)
      when "trash"
        @adv_content.update_columns(trash: true, deleted: false)
      when "deleted"
        @adv_content.update_columns(deleted: true, trash: false)
        @adv_content.adv_content_account_notifies.clear
      end
      redirect_to :back
  end

  def applications
    @applications = Application.all
    @adv_tactics = []
    @infer_applications =  @applications.select do |app|
      app.has_adv_content?(@adv_content.id)
    end
    begin_day, end_day = params[:begin], params[:end]
   #这里存在问题，应该为该广告在该应用下的展示效果
    @infer_applications.each do |app|
        statistics = app.statistics.between(begin_day, end_day).adv_content_reports(@adv_content.id)
        arry =
        [statistics.sum(:read_count), statistics.sum(:view_count), statistics.sum(:click_count), statistics.sum(:install_count)]
        app.adv_contents_params = arry
        unless app.reports.size == 0
         adv_app_report = app.reports.between(begin_day, end_day)
         warning = adv_app_report.sum(:warning_count)
         app.adv_warning = warning
        end
    end
  end

  def trash
    if current_user.role?(:admin)
      @adv_contents = AdvContent.in_trash.order("updated_at DESC")
    else
      @adv_contents = current_user.adv_contents.in_trash.order("updated_at DESC")
    end
    unless params[:search].blank?
      @adv_contents = @adv_contents.where("tag LIKE ?", "%#{params[:search].strip}%")
    end
  end


  def deleted
    if current_user.role?(:admin)
      @adv_contents = AdvContent.where(deleted: true)
    else
      @adv_contents = current_user.adv_contents.where(deleted: true)
    end
  end

  def put_trash
    if current_user.role?(:admin)
      @adv_content.toggle!(:deleted)
      flash[:notice] = "操作成功"
    else
      flash[:notice] = "操作失败"
    end
    respond_to do |format|
      format.html {redirect_to :back}
    end
  end

  def charts
    @adv_statistics =
      @adv_content.adv_statistics.between(params[:begin], params[:end])
    @adv_advertiser_reports =
      @adv_content.adv_advertiser_reports.between(params[:begin], params[:end])
    @applications = @adv_content.applications
  end

  def new
    @adv_content = AdvContent.new()
  end

  def active_content
    if @adv_content.activity == true
      @adv_content.activity = !@adv_content.activity
      @adv_content.save
      AdvTactic.del_adv_contents(@adv_content.id)
      respond_to do |format|
          flash[:notice] = "成功关闭"
          format.html { redirect_to :back }
        end
    else
      @adv_content.activity = !@adv_content.activity
      @adv_content.save
      flash[:notice] = "开启成功,请配置广告"
      redirect_to :back
    end
  end

  def edit
  end

  def update
    if @adv_content.update(adv_content_params)
      flash[:notice] = "更新成功"
      redirect_to manage_adv_content_path(@adv_content)
    else
      flash[:notice] = "更新失败"
      render 'edit'
    end
  end

  def show1

  end

  def destroy
    if @adv_content.destroy
      redirect_to manage_adv_contents_path
    end
  end

  def create
    @adv_content =  @current_user.adv_contents.build(adv_content_params)
    if @adv_content.save
      flash[:notice] = "创建成功"
      redirect_to new_manage_adv_content_adv_detail_path(@adv_content)
    else
      flash[:notice] = "创建失败"
      render 'new'
      # redirect_to :back, alter: @adv_content.errors.messages
    end
  end

  def plant

  end

  def advtatics
    @advtatics= AdvTactic.all
    @adv_tactics = @advtatics.partition do |item|
      item.adv_content_ids.include? (@adv_content.id) unless item.adv_content_ids.nil?
    end
  end

  def settings
  end

  # def promotion_info
  #   @adv_content.adv_statistics.between(params[:begin], params[:end]).sum(:install_count)
  #   @adv_content.platform_adv_statistics_sum
  # end

  def get_data
    @adv_content = AdvContent.find_by_id(params[:id])
    @install_count = @adv_content.adv_advertiser_reports.between(params[:begin], params[:end]).sum(:count)
    @last_date = "没有信息"
    @last_date = @adv_content.account_bill_infos.last.end_date unless @adv_content.account_bill_infos.last.nil?
    unless @adv_content.adv_detail.nil?
      @next_end_date = Date.parse(params[:end]) + @adv_content.adv_detail.balance_cycle.to_i
    else
      @next_end_date = params[:end]
    end
    respond_to do |format|
      format.js{render 'get_data'}
    end

  end

  def search_autocomplete
    adv_content_tag = params[:name_startsWith]
    adv_contents = AdvContent.where("tag like ? or tag like ?", "%#{adv_content_tag}%", "%#{adv_content_tag.downcase}%")
    respond_to do |format|
      format.json { render json: adv_contents, status: 200}
    end
  end

  def generate_notify
    AdvContent.where.not(deleted: true).each {|item| item.for_account_notify}
    flash[:notice] = "提醒创建完毕"
    redirect_to :back
  end



  private
    def compute_number adv_contents, sign
      adv_contents.each do |content|

      unless sign
        statistics = content.adv_statistics.between(params[:begin], params[:end])
        platform_install_count = content.platform_adv_statistics_sum(params[:begin], params[:end])
        arry =
        [statistics.sum(:read_count), statistics.sum(:view_count), statistics.sum(:click_count), statistics.sum(:install_count)]
      else
        report_days  = content.cp_report_days(params[:begin], params[:end])
        statistics = report_days.inject(sum = []) {|sum, day|  sum += content.adv_statistics.by_day(day)}
        platform_install_count = content.platform_adv_statistics_sum_in_days(report_days)

        syms = [:read_count, :view_count, :click_count, :install_count]
        arry = sum_item(statistics, syms)
      end

      content.total_install_count = arry[3]
      content.total_install_count += platform_install_count unless platform_install_count.nil?
      content.relate_params = arry
      content.income =  (content.total_install_count * content.price.to_f).round(2)

     end
    end

    def sum_item(statistics, syms)
      result = []
      syms.each do |sys|
        result << statistics.inject(sum = 0) {|sum, item| sum += item.send(sys)}
      end
      result
    end

    def set_search_date
      params[:end] = Date.today.strftime('%Y-%m-%d') if params[:end].blank?
      params[:begin] = 7.days.ago(Date.parse(params[:end])).strftime('%Y-%m-%d') if params[:begin].blank?
    end

    def set_adv_content
      @adv_content = AdvContent.find(params[:id])
    end

    def adv_content_params
      params.require(:adv_content).permit(:title, :price, :description, :apk_sign, :plan_view_count, :icon, :url, :banner, :square_banner, :user_id, :tag, :version_name, :version_code, :website)
    end

    def set_search_date
      params[:end] = Date.today.strftime('%Y-%m-%d') if params[:end].blank?
      params[:begin] = 7.days.ago(Date.parse(params[:end])).strftime('%Y-%m-%d') if params[:begin].blank?
    end

    def set_search_date_yesterday
      params[:end] = Date.today.strftime('%Y-%m-%d') if params[:end].blank?
      params[:begin] = 1.days.ago(Date.parse(params[:end])).strftime('%Y-%m-%d') if params[:begin].blank?
    end

    def set_search_state
      params[:state] = "on" if params[:state].nil?
    end

    def state_to_sql state
      case state
      when "on"
        "where deleted = false and trash = false"
      when "trash"
        "where trash = true"
      when "deleted"
        "where deleted = true"
      end
    end

    def download_xlsx_name adv_contents
      hash = {}
      hash[:template_file] = "adv_content_index" if params[:history]
      hash[:template_file] ||= "index"

      hash[:filename] = if adv_contents.size > 1
        "#{params[:begin]}--#{params[:end]}.xlsx"
      else
        "#{adv_contents.first.try(:title)}#{params[:begin]}--#{params[:end]}.xlsx"
      end
      hash
    end
end
