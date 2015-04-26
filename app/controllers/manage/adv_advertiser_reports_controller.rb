class Manage::AdvAdvertiserReportsController < ApplicationController
  before_action :set_adv_content, except: :all
  before_action :set_adv_advertiser_report, only: [:show, :update, :edit, :destroy, :inde]
  before_action :set_search_date, only: [:index]
  def index
    @adv_advertiser_reports  = @adv_content.adv_advertiser_reports.between(params[:begin], params[:end]).page(params[:page]).per(params[:per]).order("created_at DESC")
  end
  def all
    if current_user.role?(:admin)
      @adv_advertiser_reports = AdvAdvertiserReport.all.page(params[:page]).per(params[:per])
      render 'all'
    end
  end

  def show
  end

  def create
    @adv_advertiser_report = @adv_content.adv_advertiser_reports.build(adv_advertiser_reports_params)
    if @adv_advertiser_report.save
      flash[:notice] = "Successfully created..."
      render 'show'
    else
      flash[:notice] = "failed  created..."
      render 'new'
    end
  end

  def new
    @adv_advertiser_report = AdvAdvertiserReport.new
  end

  def update
    if @adv_advertiser_report.update(adv_advertiser_reports_params)
      flash[:notice] = "Successfully update..."
      render 'show'
    else
      flash[:notice] = "failed update..."
      render 'show'
    end
  end

  def destroy
    if @adv_advertiser_report.destroy
      flash[:notice] = "Successfully  destory..."
      redirect_to manage_adv_content_adv_advertiser_reports_path(@adv_content)
    else
      flash[:notice] = "failed destroy..."
      render 'show'
    end
  end

  def edit
  end

  private

  def adv_advertiser_reports_params
    params.require(:adv_advertiser_report).permit(:count, :report_date)
  end

  def set_adv_content
    @adv_content = AdvContent.find(params[:adv_content_id])
  end

  def set_adv_advertiser_report
    @adv_advertiser_report = AdvAdvertiserReport.find(params[:id])
  end
    def set_search_date
      params[:end] = Date.today.strftime('%Y-%m-%d') if params[:end].blank?
      params[:begin] = 7.days.ago(Date.parse(params[:end])).strftime('%Y-%m-%d') if params[:begin].blank?
    end

end
