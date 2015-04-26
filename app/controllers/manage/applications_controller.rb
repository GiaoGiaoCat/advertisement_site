# encoding: utf-8
class Manage::ApplicationsController < ApplicationController
  before_action :set_application, only: [:charts, :show, :edit, :update, :destroy, :adv_settings, :adv_contents, :copy_channel, :del_adv_content]

  before_action :set_search_date, only: [:charts, :list, :index, :activity_app]
  authorize_resource
  PAGESIZE = 50
  # GET /manage/applications
  # GET /manage/applications.json
  def index
    if current_user.role?(:admin)
      @title = "平台应用管理"
      @applications = Application.order("display_advertising  DESC,created_at DESC")
      @applications.each do |app|
        statistics = app.statistics.between(params[:begin], params[:end])
        arry =
        [statistics.sum(:read_count), statistics.sum(:view_count), statistics.sum(:click_count), statistics.sum(:install_count)]
        app.adv_contents_params = arry
        adv_app_report = app.reports.between(params[:begin], params[:end])
        warning = adv_app_report.sum(:warning_count)
        app.adv_warning = warning
      end
    else
      @title = "应用列表"
      @applications = current_user.applications.order("display_advertising , created_at DESC")
    end
  end

  def activity_app
    # binding.pry
    @adv_content = AdvContent.find_by_id(params[:adv_content_id])
    @play_advertising_app = Application.play_advertising
    @play_advertising_app.each do |app|
      statistics = app.statistics.yesterday
      arry =
      [statistics.sum(:read_count), statistics.sum(:view_count), statistics.sum(:click_count), statistics.sum(:install_count)]
      app.adv_contents_params = arry
      warning = app.reports.yesterday.sum(:warning_count)
      app.adv_warning = warning
    end
  end

  def list
    # @applications = Application.ordered_by_view_count.page(params[:page])
    @applications = Application.where("display_advertising = ?", 1).page(params[:page]).per(50)
  end

  def charts
    @adv_statistics = @application.statistics.between(params[:begin], params[:end])
    @adv_contents = []
    @adv_statistics.each do |item|
      @adv_contents << item.adv_content unless item.adv_content.nil?
    end
  end

  # GET /manage/applications/1
  # GET /manage/applications/1.json
  def show
    @profile = @application.user.try(:profile) if @application.user
  end

  # GET /manage/applications/new
  def new
    @application = current_user.applications.new
  end

  # GET /manage/applications/1/edit
  def edit
  end

  # POST /manage/applications
  # POST /manage/applications.json
  def create
    @application = current_user.applications.new(application_params)

    respond_to do |format|
      if @application.save
        format.html { redirect_to manage_application_path(@application), notice: 'Application was successfully created.' }
        format.json { render action: 'show', status: :created, location: @application }
      else
        format.html { render action: 'new' }
        format.json { render json: @application.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /manage/applications/1
  # PATCH/PUT /manage/applications/1.json
  def update
    respond_to do |format|
      if @application.update(application_params)
        format.html { redirect_to manage_applications_path(@application), notice: 'Application was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @application.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /manage/applications/1
  # DELETE /manage/applications/1.json
  def destroy
    @application.destroy
    respond_to do |format|
      format.html { redirect_to manage_applications_url }
      format.json { head :no_content }
    end
  end

  def adv_settings
    @adv_settings = @application.adv_settings.page(params[:page])
  end

  def adv_contents
    @adv_contents = @application.get_adv_contents.page(params[:page])
    @adv_contents.each do |adv_content|
        statistics = adv_content.adv_statistics.application_reports(@application.id).yesterday
        arry =
        [statistics.sum(:read_count), statistics.sum(:view_count), statistics.sum(:click_count), statistics.sum(:install_count)]
        adv_content.relate_params = arry
      end
  end

  def multi
    ids = params[:ids]
    @applications = Application.where(id: ids)
    @adv_content_id = params[:adv_content_id]
  end

  def copy_channel
    @adv_setting = AdvSetting.find_by_id(params[:adv_setting_id])
    unless @adv_setting.nil?
      infer_setting = @adv_setting.deep_dup()
      tactics = @adv_setting.adv_tactics.each do |tactic|
          infer_setting.adv_tactics << tactic.deep_dup()
      end
      @application.adv_settings << infer_setting
      flash[:notice] = "拷贝成功"
    end
      redirect_to adv_settings_manage_application_path(@application)
  end

  def del_adv_content
    unless params[:adv_content_id].nil?
      @application.adv_contents.destroy(AdvContent.where(id: params[:adv_content_id]))
      @application.adv_tactics.each do |tactic|
      tactic.del_adv_content(params[:adv_content_id])
      tactic.save
      end
      flash[:notice] = "操作成功"
    else
      flash[:notice] = "操作失败"
    end
    redirect_to :back
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      # 这里不要使用关联查询 @application = current_user.applications.find(params[:id])
      # SELECT `applications`.* FROM `applications` WHERE `applications`.`user_id` = 2 AND `applications`.`id` = 5 LIMIT 1
      # 这种用法跳过了 Encrpyt ID 重写的 find 方法，造成加密的 id 没有解析，无法正确找到数据。
      @application = Application.find(params[:id])
    end

    def set_application_by_id
       @application = Application.find_by_id(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def application_params
      params.require(:application).permit(:name, :platform, :description, :display_advertising)
    end

    def set_search_date
      params[:end] = Date.today.strftime('%Y-%m-%d') if params[:end].blank?
      params[:begin] = 7.days.ago(Date.parse(params[:end])).strftime('%Y-%m-%d') if params[:begin].blank?
    end

end
