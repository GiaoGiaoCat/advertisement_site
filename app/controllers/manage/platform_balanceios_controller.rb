class Manage::PlatformBalanceiosController < ApplicationController
  authorize_resource
  before_action :set_platform
  before_action :set_platform_account, except: :balanceio
  before_action :set_platform_balanceio, only: [:edit, :show, :update, :destroy]
  before_action :set_search_date_yesterday, only: [:index]
  # GET /manage/users
  # GET /manage/users.json
  def index
    @platform_balanceios =  @platform_account.platform_balanceios.between(params[:begin], params[:end])
  end

  # GET /manage/user/new
  def new
    @platform_balanceio = PlatformBalanceio.new
  end

  # GET /manage/users/1
  # GET /manage/users/1.json
  def show
  end

  # POST /manage/user
  # POST /manage/user.json
  def create
    @platform_balanceio= @platform_account.platform_balanceios.build platform_balanceios_params
    respond_to do |format|
      if @platform_balanceio.save
        format.html { redirect_to manage_platform_platform_account_platform_balanceios_path(@platform, @platform_account), notice: 'User was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def balanceio
    @platform_account = PlatformAccount.find(params[:platform_balanceio][:platform_account_id]) unless params[:platform_balanceio][:platform_account_id].blank?
    unless @platform_account.nil?
      @platform_balanceio= @platform_account.platform_balanceios.build platform_balanceios_params
      respond_to do |format|
        if @platform_balanceio.save
          format.html { redirect_to manage_platform_platform_account_platform_balanceios_path(@platform, @platform_account), notice: 'User was successfully created.' }
        else
          flash[:notice] = "创建失败"
          format.html { redirect_to :back}
        end
      end
    else
      flash[:notice] = "创建失败，请填写正确信息"
      redirect_to :back
    end
  end
  # PATCH/PUT /manage/users/1
  # PATCH/PUT /manage/users/1.json
  def update
    @platform_balanceio.update(platform_balanceios_params)
    if @platform_balanceio.save
      redirect_to manage_platform_platform_account_platform_balanceios_path(@platform, @platform_account)
    else
      render 'edit'
    end
  end

  def destroy
    @platform_balanceio.destroy
    redirect_to manage_platform_platform_account_platform_balanceios_path(@platform, @platform_account)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def platform_balanceios_params
      params.require(:platform_balanceio).permit(:platform_account_id, :adv_content_id, :money, :report_date)
    end
    def set_platform
      @platform = Platform.find(params[:platform_id])
    end


    def set_platform_balanceio
      @platform_balanceio= PlatformBalanceio.find(params[:id])
    end

    def set_platform_account
      @platform_account = PlatformAccount.find(params[:platform_account_id])
    end

    def set_search_date_yesterday
      params[:end] = Date.today.strftime('%Y-%m-%d') if params[:end].blank?
      params[:begin] = 1.days.ago(Date.parse(params[:end])).strftime('%Y-%m-%d') if params[:begin].blank?
    end
end
