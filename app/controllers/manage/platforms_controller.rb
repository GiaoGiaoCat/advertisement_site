class Manage::PlatformsController < ApplicationController
  authorize_resource
  # GET /manage/users
  # GET /manage/users.json
  before_action :set_platform, only: [:show, :update, :edit, :destroy, :adv_contents, :platform_balanceios]
  before_action :set_search_date, only: [:index, :adv_contents]

  before_action :set_search_date, only: [:index, :adv_contents]
  def adv_contents
    infer_ids= @platform.platform_statistics.between(params[:begin], params[:end]).pluck(:adv_content_id)
    ids =  @platform.adv_content_ids | infer_ids
    @adv_contents =  AdvContent.where(id: ids )
  end

  def index
    @platforms = Platform.all.page(params[:page]).per(50)
  end

  # GET /manage/user/new
  def new
    @platform = Platform.new
  end

  # GET /manage/users/1
  # GET /manage/users/1.json
  def show
  end

  def edit
  end

  # POST /manage/user
  # POST /manage/user.json
  def create
    @platform = Platform.new(platform_params)
    respond_to do |format|
      if @platform.save
        format.html { redirect_to manage_platforms_path, notice: 'platform was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  def platform_balanceios
    @platform_balanceio = PlatformBalanceio.new
  end
  # PATCH/PUT /manage/users/1
  # PATCH/PUT /manage/users/1.json
  def update
    @platform.update(platform_params)
    if @platform.save
      redirect_to manage_platforms_path
    else
      render 'new'
    end
  end

  def destroy
    @platform.destroy
    redirect_to manage_platforms_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_platform
      @platform = Platform.find(params[:id])
    end

    def platform_params
      params.require(:platform).permit(:name, adv_content_ids: [])
    end

    def set_search_date
      params[:end] = Date.today.strftime('%Y-%m-%d') if params[:end].blank?
      params[:begin] = 7.days.ago(Date.parse(params[:end])).strftime('%Y-%m-%d') if params[:begin].blank?
    end

    def set_search_date
      params[:end] = Date.today.strftime('%Y-%m-%d') if params[:end].blank?
      params[:begin] = 7.days.ago(Date.parse(params[:end])).strftime('%Y-%m-%d') if params[:begin].blank?
    end
end
