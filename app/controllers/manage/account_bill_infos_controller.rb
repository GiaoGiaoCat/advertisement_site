class Manage::AccountBillInfosController < ApplicationController
  before_action :set_account_bill, only: [:index, :show, :update, :destroy, :new, :create, :edit]
  before_action :set_account_bill_info, only: [:show, :update, :destroy, :edit]
  before_action :set_search_date, only: [:index]

  def index
    @account_bill_infos = @account_bill.account_bill_infos
  end

  def create
    @account_bill_info = @account_bill.account_bill_infos.build account_bill_info_params
    if @account_bill_info.save
        @account_bill_info.adv_content.account_notify_changes(@account_bill_info.start_date, @account_bill_info.end_date)
        unless @account_bill_info.adv_content.adv_detail.nil?
          @account_bill_info.adv_content.adv_detail.update_attributes(balance_first_date: params[:account_bill_info][:next_end_date])
        end
      redirect_to manage_account_bill_account_bill_infos_path(@account_bill)
    else
      flash[:notice] = "创建失败"
      render 'new'
    end
  end

  def show
  end

  def edit
    render 'edit'
  end

  def update
    @account_bill_info.update(account_bill_info_params)
    if @account_bill_info.save
      redirect_to manage_account_bill_account_bill_infos_path(@account_bill)
    else
      flash[:notice] = "Successfully created..."
      render 'edit'
    end
  end

  def new
    @account_bill_info = AccountBillInfo.new
    respond_to do |format|
      format.html{render 'new'}
      format.js{render "new"}
    end
  end

  def destroy
    @account_bill_info.destroy
    redirect_to :back
  end

  private

    def set_account_bill
      @account_bill = AccountBill.find(params[:account_bill_id])
    end

    def account_bill_info_params
      params.require(:account_bill_info).permit(:account_bill_id, :adv_content_id, :start_date, :amount, :end_date, :price)
    end

    def set_search_date
      params[:end] = Date.today.strftime('%Y-%m-%d') if params[:end].blank?
      params[:begin] = 1.days.ago(Date.parse(params[:end])).strftime('%Y-%m-%d') if params[:begin].blank?
    end

    def set_account_bill_info
      @account_bill_info = AccountBillInfo.find(params[:id])
    end
end
