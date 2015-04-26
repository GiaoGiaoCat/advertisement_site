class Manage::AdvContentAccountNotifiesController < ApplicationController

  before_action :set_adv_content_account_notify, only: [:show, :destroy]

  def index
   @adv_content_notifies = AdvContentAccountNotify.all
  end

  def  show
  end

  def destroy
   @adv_content_account_notify.destroy
   redirect_to :back
  end

  private

  def set_adv_content_account_notify
    @adv_content_account_notify = AdvContentAccountNotify.find(params[:id])
  end
end
