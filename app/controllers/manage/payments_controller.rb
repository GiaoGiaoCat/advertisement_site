# encoding: utf-8
class Manage::PaymentsController < ApplicationController
  before_action :set_payment, only: [:show]

  authorize_resource

  # GET /manage/payments
  # GET /manage/payments.json
  def index
    if current_user.role?(:admin) && params[:admin] == "true"
      @title = "平台提现管理"
      @payments = Payment.order("updated_at DESC").page(params[:page])
    else
      @title = "提现明细"
      @payments = current_user.payments.order("updated_at DESC").page(params[:page])
    end
  end

  # GET /manage/payments/new
  def new
    @payment = current_user.payments.new
  end

  # POST /manage/payments
  # POST /manage/payments.json
  def create
    @payment = current_user.payments.new(payment_params)

    respond_to do |format|
      if @payment.save
        format.html { redirect_to manage_payments_path, notice: 'Payment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @payment }
      else
        format.html { render action: 'new' }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /manage/payments/1
  # PATCH/PUT /manage/payments/1.json
  def update_state
    @payments = Payment.where(:id => params[:ids])
    respond_to do |format|
      if @payments.update_all(state: admin_params[:state])
        format.html { redirect_to manage_payments_path(admin: true), notice: 'Payment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to manage_payments_path(admin: true) }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_params
      params.require(:payment).permit(:amount)
    end

    def admin_params
      params.permit(:state)
    end
end
