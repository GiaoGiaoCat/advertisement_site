# encoding: UTF-8
class Manage::AdvSettingsController < ApplicationController
  before_action :set_adv_setting, only: [:edit, :update, :active_setting, :destroy]
  def index
    @adv_settings = AdvSetting.page(params[:page]).per(params[:per])
  end

  def new
      @adv_setting = AdvSetting.new
      @application = Application.find_by_id(params[:application_id])
  end

  def default_channel
    @application = Application.find_by_id(params[:application_id])
    content = Hash.new
    content[:channel]  = "默认渠道"
    content[:product_name]  = @application.name
    content[:activity]  = true
    content[:block]  = true
    @adv_setting = @application.adv_settings.build(content)
    @adv_setting.save
    render 'edit'
  end

  def create
    adv_setting =  AdvSetting.new(adv_setting_params)
    adv_setting.product_name = Application.find_by_id(adv_setting.application_id).name
    if adv_setting.save
      redirect_to adv_settings_manage_application_path(Application.find_by_id adv_setting_params[:application_id])
    else
      redirect_to :back, alert: adv_setting.errors.full_messages.first
    end

  end

  def edit
  end

  def update
    if @adv_setting.update_attributes adv_setting_params
      redirect_to adv_settings_manage_application_path(@adv_setting.application), notice: '更新成功'
    else
      render 'edit'
    end
  end

  def destroy
      application = @adv_setting.application
       @adv_setting.destroy
       redirect_to  adv_settings_manage_application_path(application)
  end

  def active_setting
     @adv_setting.activity = ! @adv_setting.activity
    respond_to do |format|
      if  @adv_setting.save
        @adv_settings = AdvSetting.page(params[:page]).per(params[:per])
        format.js {
          render 'reload_adv_settings_list'
        }
      end
    end
  end

  def multi
    ids = params[:ids]
    @adv_settings = AdvSetting.where(id: ids)
    @adv_content_id = params[:adv_content_id]
  end

  private

  def adv_setting_params
    params.require(:adv_setting).permit(:channel, :product_name, :activity, :block, :application_id,)
  end

  def set_adv_setting
     @adv_setting = AdvSetting.find_by_id params[:id]
  end
end
