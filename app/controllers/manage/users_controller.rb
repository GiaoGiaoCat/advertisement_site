class Manage::UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update]
  before_filter :create_allow, only: [:create, :update]
  before_filter :edit_allow, only: [:edit, :update, :show]

  authorize_resource

  # GET /manage/users
  # GET /manage/users.json
  def index
    if current_user.role?(:spreader)
    end
    @users = User.staff_members.page(params[:page])
  end

  def search
    unless params[:search].blank?
      @users = User.where("email like ?", "%#{params[:search]}%").page(params[:page])
      render 'index'
    else
      redirect_to manage_users_path
    end
  end
  # GET /manage/user/new
  def new
    @user = User.new
  end

  # GET /manage/users/1
  # GET /manage/users/1.json
  def show
    @profile = @user.profile
  end

  # POST /manage/user
  # POST /manage/user.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to manage_user_path(@user), notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /manage/users/1
  # PATCH/PUT /manage/users/1.json
  def update
    successfully_updated = if needs_password?
      @user.update(user_params)
    else
      @user.update_without_password(user_params)
    end

    respond_to do |format|
      if successfully_updated
        format.html { redirect_to manage_users_path, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :username, :role, :password, :password_confirmation)
    end

    def needs_password?
      user_params[:password].present?
    end

    def create_allow
      if  !User::USERROLES[current_user.role].nil? && User::USERROLES[current_user.role].include?(params[:user][:role])
        return true
      else
        flash[:notice] = "权限不足"
        redirect_to :back
      end
    end

    def edit_allow
      user = User.find(params[:id])
      if  !User::USERROLES[current_user.role].nil? && !user.nil? && User::USERROLES[current_user.role].include?(user.role)
        return true
      else
        flash[:notice] = "权限不足"
        redirect_to :back
      end
    end

end
