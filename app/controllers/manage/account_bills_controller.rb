class Manage::AccountBillsController < ApplicationController

  before_action :set_account_bill, only: [:show, :update, :destroy, :create_new, :change_state, :edit, :add_image, :payed_invoice, :pay_confirm, :update_all, :admin_update]
  before_action :set_search_date, only: [:index]
  before_action :set_search_params, only: [:index]

  def index
    search_scope, invoice_state_scope = search_params_translate(params[:state], params[:invoice_state])

    if current_user.role?(:channel_manager)
        @account_bills = current_user.account_bills
    else
        @account_bills = AccountBill.all
    end
    @account_bills = @account_bills.where(state: search_scope).where(invoice_state: invoice_state_scope).between(params[:begin], params[:end]).page(params[:page]).per(50)

    if current_user.role?(:admin)
       admin_index_view
    end
  end

  def create
    @account_bill  = AccountBill.new(account_bill_params)
    @account_bill.state = AccountBill::UN_CHECKED
    @account_bill.amount = 0
      current_user.account_bills << @account_bill unless current_user.role?(:admin)
    @account_bill.save
    redirect_to manage_account_bill_account_bill_infos_path(@account_bill)
  end

  def show
    redirect_to manage_account_bill_account_bill_infos_path(@account_bill)
  end

  def edit
    @total_amount = @account_bill.account_bill_infos.sum(:amount)
    @total_balance = @account_bill.account_bill_infos.inject(0.0) {|sum, account_bill| sum += account_bill.total_balance()}
    respond_to do |format|
      format.js{render 'edit_account_bill'}
      format.html{render 'edit'}
    end
  end

  def add_image
    respond_to do |format|
      format.js{render 'add_image'}
      format.html{render 'add_image'}
    end
  end


  def change_state
    @account_bill.update_attributes(state: params[:state])
    if @account_bill.save
       @account_bill.update_column(:invoice_state, AccountBill::INVOICE_NO_NEDD) if params[:state].to_i == AccountBill::PAYED_NUM_NOT_RIGHT
      flash[:notice] = "状态更新成功"
    else
      flash[:notice] = " 状态更新失败"
    end
      redirect_to :back
  end

  def update
    @account_bill.update(account_bill_params)
    if @account_bill.save
      if params[:checked]
        if account_bill_params[:details] || @account_bill.details.url
          @account_bill.update_column(:state, AccountBill::CHECKED)
          @account_bill.update_column(:state, AccountBill::STOP_WAIT_TO_PAY) if params[:stop_wait_to_pay]
        else
          flash[:notice] = "对账确认请上传对账信息"
        end
      end
      redirect_to manage_account_bill_account_bill_infos_path(@account_bill)
    else
      flash[:notice] = "更新失败"
      if params[:add_image]
        redirect_to :back
      else
        redirect_to manage_account_bill_account_bill_infos_path(@account_bill)
       end
    end
  end

  def pay_confirm
    @account_bill.update(account_bill_params)
    if (account_bill_params[:pay_money_pic] || @account_bill.pay_money_pic.url) && account_bill_params[:expect_to_account_date]
      if @account_bill.save
        @account_bill.update_column(:state, AccountBill::COMMERCE_CONFIRME)
        redirect_to manage_account_bill_account_bill_infos_path(@account_bill)
      else
        flash.now[:notice] = "信息不完全, 请填写图片，和到账日期"
        render 'add_image'
      end
    else
      flash.now[:notice] = "信息不完全, 请填写图片，和到账日期"
      render 'add_image'
    end
  end

  def new
    @account_bill = AccountBill.new
    respond_to do |format|
      format.js{render "new"}
    end
  end

  def payed_invoice
    @account_bill.update_column(:invoice_state, AccountBill::INVOICE_PAYED)
    redirect_to :back
  end

  def destroy
    @account_bill.destroy
    redirect_to manage_account_bills_path
  end

  def create_new
  end

  def update_all
    unless current_user.role?(:admin)
      flash[:notice] = "没有权限"
      redirect_to manage_account_bill_account_bill_infos_path(@account_bill)
      return
    end
  end

  def admin_update
    unless current_user.role?(:admin)
      flash[:notice] = "Successfully created..."
      redirect_to :back
      return
    end
    @account_bill.update(account_bill_params)
    if @account_bill.save
      flash[:notice] = "Successfully created..."
      redirect_to manage_account_bill_account_bill_infos_path(@account_bill)
    else
      flash.now[:notice] = "Successfully created..."
      render 'update_all'
    end
  end


  private
    def admin_index_view
      begin_day = Date.parse(params[:begin])
      end_day = Date.parse(params[:end])
      adv_content_ids = AdvContent.not_in_trash.joins(:adv_statistics).where("adv_statistics.created_at > ? AND adv_statistics.created_at < ?", begin_day.midnight.to_time, end_day.at_end_of_day.to_time).group("adv_contents.id").having("sum(adv_statistics.install_count) > 0").pluck(:id)
      @adv_contents = AdvContent.where(id: adv_content_ids)

      @platform_balance_count = Platform.all.inject(0.0){|sum, platform| sum += platform.balance_total_to_lable(params[:begin], params[:end])}
    end

    def set_account_bill
      @account_bill = AccountBill.find(params[:id])
    end

    def account_bill_params
      params.require(:account_bill).permit(:balance, :company, :state, :amount, :balance, :user_id, :expect_to_account_date, :pay_money_pic, :is_public, :tax, :after_tax_balance, :invoice_state, :details)
    end

    def set_search_date
      params[:end] = Date.today.yesterday.strftime('%Y-%m-%d') if params[:end].blank?
      params[:begin] = 30.days.ago(Date.parse(params[:end])).strftime('%Y-%m-%d') if params[:begin].blank?
    end

    def set_search_params
      default_search_params = AccountBill::user_search_params_permit(current_user)
      if params[:state].blank? ||  (!default_search_params.include?(params[:state].to_i))
        params[:state] = AccountBill::ALL
      end

      if params[:invoice_state].blank? || (!AccountBill::INVOICE_STATE.values.include?(params[:invoice_state].to_i))
        params[:invoice_state] = AccountBill::INVOICE_STATE_ALL
      end
    end

    def search_params_translate  state, invoice_state
      result = []
      result << (state.to_i == 0 ? AccountBill::user_search_params_permit(current_user) : state)
      result << case invoice_state.to_i
          when 3 then [1, 2]
          when 4 then [0, 1, 2]
          else
            invoice_state
          end
      result
    end
end
