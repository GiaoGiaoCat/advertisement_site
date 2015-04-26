class Manage::AdvDetailsController < ApplicationController
  before_action :set_adv_content
  before_action :set_adv_detail, only: [:show, :destroy, :update, :edit, :create]

  def index
    @adv_detail = @adv_content.adv_detail
    if @adv_detail.nil?
      flash[:notice] = "还没有关联信息"
      redirect_to new_manage_adv_content_adv_detail_path(@adv_content)
    else
      render 'show'
    end
  end

  def create
    @adv_detail = @adv_content.build_adv_detail(adv_details_params)
    if @adv_detail.save
      flash[:notice] = "Successfully created..."
      redirect_to manage_adv_content_adv_detail_path(@adv_content, @adv_detail)
    else
      flash[:notice] = "failed created..."
      redirect_to :back
    end
  end

  def new
    @adv_detail = AdvDetail.new
  end

  def destroy
    @adv_detail.destroy
    redirect_to manage_adv_contents_path
  end

  def edit
  end

  def update
   if  @adv_detail.update(adv_details_params)
      flash[:notice] = "Successfully updated..."
      render 'show'
    else
      flash[:notice] = "failed  updated..."
      render 'edit'
    end
  end

  def show
  end

  private

  def adv_details_params
    params.require(:adv_detail).permit(:origin, :cooperation, :price, :calculate_mode, :balance_requirement, :balance_instruction,:balance_cycle, :balance_first_date, :promotion_requirement, :manage_site, :manage_site_user, :manage_site_password, :company, :name, :phone, :qq, :postcode, :address, :cooperation_mode)
  end

  def set_adv_detail
    @adv_detail = AdvDetail.find_by_id(params[:id])
  end

  def set_adv_content
   @adv_content = AdvContent.find(params[:adv_content_id])
 end
end
