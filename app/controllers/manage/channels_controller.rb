# encoding: utf-8
class Manage::ChannelsController < ApplicationController

  load_and_authorize_resource

  # GET /manage/channels
  def index
    @channels =
      if current_user.role?(:admin)
        Channel.page(params[:page])
      elsif current_user.role?(:channel_manager)
        Channel.where(manager_id: current_user.id).page(params[:page])
      end
  end

  # GET /manage/channels/new
  def new
  end

  def create_apk
  end

  # GET /manage/channels/1/edit
  def edit
  end

  # POST /manage/channels
  def create
    @channel = Channel.new(channel_params)

    respond_to do |format|
      if @channel.save
        format.html { redirect_to manage_channels_path, notice: 'Channel was successfully created.' }
        format.json { render action: 'show', status: :created, location: @channel }
      else
        format.html { render action: 'new' }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /manage/channels/1
  def update
    respond_to do |format|
      if @channel.update(channel_params)
        format.html { redirect_to manage_channels_path, notice: 'Channel was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end


  private
    def replace_manager_id
      params[:channel][:manager_id] = current_user.id if current_user.role?(:channel_manager)
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    def channel_params
      replace_manager_id
      params.require(:channel).permit(:name, :user_id, :enabled, :price, :manager_id, :level, :auto_ratio, :auto_ratio_activate_at)
    end

end
