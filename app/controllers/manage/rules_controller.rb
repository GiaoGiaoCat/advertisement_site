class Manage::RulesController < ApplicationController
  before_action :set_channel, only: [:index, :new, :create, :edit, :update]

  authorize_resource

  def index
    @rules = @channel.rules.page(params[:page])
  end

  def new
    @rule = @channel.rules.new
  end

  def create
    @rule = @channel.rules.new(rule_params)

    respond_to do |format|
      # HACK:
      # relate_applications method is a bad way to save applications.
      # because encrypted_id gem could not finds application when save @rule.
      if @rule.save && @rule.relate_applications(find_applications)
        format.html { redirect_to manage_channel_rules_path(@channel), notice: 'Rule was successfully created.' }
        format.json { render action: 'show', status: :created, location: @channel }
      else
        format.html { render action: 'new' }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @rule = Rule.find(params[:id])
  end

  def update
    @rule = Rule.find(params[:id])

    respond_to do |format|
      # HACK:
      # relate_applications method is a bad way to save applications.
      # because encrypted_id gem could not finds application when save @rule.
      if @rule.update(rule_params) && @rule.relate_applications(find_applications)
        format.html { redirect_to manage_channel_rules_path(@channel), notice: 'Rule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_channel
      @channel = Channel.find(params[:channel_id])
    end

    def rule_params
      params.require(:rule).permit(:name, :enabled, :ratio, :activate_at)
    end

    def find_applications
      applications = []
      params[:rule][:application_ids].each do |app_id|
        applications << Application.find(app_id) unless app_id.blank?
      end
      applications
    end
end
