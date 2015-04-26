class Manage::AdvTacticsController < ApplicationController
   before_action :set_adv_tactic, except: [:new, :create, :index, :destroy, :multi]
   before_action :set_adv_setting ,except: :multi
  def index
    @adv_tactics = @adv_setting.adv_tactics
    @adv_contents = AdvContent.all.order("created_at DESC")
  end

  def new
    @adv_tactic = AdvTactic.new
      respond_to do |format|
        format.js {render 'new_adv_tactics'}
        format.html {render 'new'}
      end
  end

  def edit
      respond_to do |format|
           format.html {render "edit"}
           format.js {
            render 'edit_adv_tactics'
      }
    end
  end

  def create
    @adv_tactic = @adv_setting.adv_tactics.build(adv_tactic_params)
    if @adv_tactic.save
      respond_to do |format|
        flash[:notice] = "创建成功"
        format.js{render 'blank'}
        format.html{ redirect_to :back}
      end
    else
      respond_to do |format|
        flash[:notice] = "创建失败"
      format.html{render 'new'}
      format.js{render 'edit_adv_tactics', notice: '创建失败'}
    end
    end
  end

  def update
    if @adv_tactic.update_attributes adv_tactic_params
      respond_to do |format|
        flash[:notice] = 'update success'
        format.js{render 'blank', notice: 'update success'}
        format.html{redirect_to adv_tactics_path, notice: 'update success'}
       end
    else
      respond_to do |format|
        format.js{render 'blank', notice: 'update success'}
        render 'edit'
       end
    end
  end

  def destroy
    tactic = AdvTactic.find params[:id]
    respond_to do |format|
      tactic.destroy
      @adv_tactics = AdvTactic.page(params[:page]).per(params[:per])
      flash[:notice] = "删除成功"
      format.html{redirect_to :back}
    end
  end

  def show_adv_tactics
   adv_settings = AdvSetting.find_by_id(params[:adv_setting_id])
   @adv_tactics =  adv_settings.adv_tactics
  end

  def make_relationship
    @adv_tactic.assgin_adv_content params[:adv_content_id]
    if @adv_tactic.save
      flash[:notice] = "Successfully created..."
    else
      flash[:notice] = "failed created..."
    end
    redirect_to :back
  end

  def  del_relationship
    @adv_tactic.del_adv_content params[:adv_content_id]
    if @adv_tactic.save
      flash[:notice] = "Successfully created..."
    else
      flash[:notice] = "failed created..."
    end
    redirect_to :back
  end

  def multi
    @adv_tactics = AdvTactic.where(id: params[:ids])
    unless params[:adv_content_id].nil?
      adv_content_id = params[:adv_content_id]
      flash[:notice] = "广告配置成功"
      @adv_tactics.each do |tactic|
          tactic.assgin_adv_content(adv_content_id)
      end
    else
      flash[:notice] = "广告配置失败"
    end
      redirect_to manage_adv_contents_path
  end

  def sort_adv_content

  end

  def sort_result
    adv_content_ids  = []
    params[:adv_content].each do |id|
      adv_content_ids << AdvContent.find(id).id unless AdvContent.find(id).nil?
    end
    @adv_tactic.adv_content_ids = adv_content_ids
    if @adv_tactic.save
      render :text => " 顺序保存成功"
    else
      render :text => "顺序保存失败"
    end
  end


  private

  def adv_tactic_params
    params.require(:adv_tactic).permit(:notice_type, :adv_settings, :value, :action, :adv_setting_id, adv_content_ids: [])
  end

  def set_adv_tactic
    @adv_tactic = AdvTactic.find(params[:id])
  end
  def set_adv_setting
    @adv_setting = AdvSetting.find_by_id(params[:adv_setting_id])
  end

end
