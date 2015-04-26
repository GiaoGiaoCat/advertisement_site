class Manage::PlatformAccountsController < ApplicationController
  authorize_resource
  before_action :set_platform
  before_action :set_platform_account, only: [:edit, :show, :update, :destroy]
  # GET /manage/users
  # GET /manage/users.json
  def index
    @platform_accounts =  @platform.platform_accounts
    unless current_user.role?(:secretary)
        set_search_date
        render 'index'
      else
        render 'secretary'
    end
  end

  # GET /manage/user/new
  def new
    @platform_account = PlatformAccount.new
  end

  def edit
  end
  # GET /manage/users/1
  # GET /manage/users/1.json
  def show
  end

  # POST /manage/user
  # POST /manage/user.json
  def create
    @platform_account = @platform.platform_accounts.build platfrom_account_params

    respond_to do |format|
      if @platform_account.save
        format.html { redirect_to manage_platform_platform_accounts_path(@platform), notice: '帐号新建成功' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /manage/users/1
  # PATCH/PUT /manage/users/1.json
  def update
    @platform_account.update platfrom_account_params
    respond_to do |format|
      if @platform_account.save
        format.html { redirect_to manage_platform_platform_accounts_path(@platform), notice: '帐号更新成功' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def destroy
    if @platform_account.destroy
      redirect_to manage_platform_platform_accounts_path(@platform), notice: '帐号删除成功'
    else
      redirect_to manage_platform_platform_accounts_path(@platform), notice: '帐号删除失败'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def platfrom_account_params
      params.require(:platform_account).permit(:account_name, :last_input, :balance)
    end

    def set_platform
      @platform = Platform.find(params[:platform_id])
    end

    def set_platform_account
      @platform_account = PlatformAccount.find(params[:id])
    end

    def set_search_date
      params[:end] = Date.today.strftime('%Y-%m-%d') if params[:end].blank?
      params[:begin] = 1.days.ago(Date.parse(params[:end])).strftime('%Y-%m-%d') if params[:begin].blank?
    end
end
