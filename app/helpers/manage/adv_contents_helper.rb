# encoding: utf-8
module Manage::AdvContentsHelper
  def display_sum_count(objs, action_type, mark = "，")
    action, numbers =
      case action_type
      when :view
        ["展示", sum_count(objs.chart_data(:view_count))]
      when :click
        ["点击", sum_count(objs.chart_data(:click_count))]
      when :install
        ["安装", sum_count(objs.chart_data(:install_count))]
      when :active
        ["激活", sum_count(objs.chart_data(:count))]
      else
        ["其它", 0]
      end
    "#{action} #{numbers} 次#{mark}"
  end
  def is_adv_content_activity? content
    if content.activity
      link_to '关闭', active_content_manage_adv_content_path(content), method: :post, class: 'btn btn-mini btn-danger'
    else
      link_to '激活', active_content_manage_adv_content_path(content), method: :post, class: 'btn btn-mini btn-success'
    end
  end

  def compute_income_relate one, two
     if two == 0
      return 0
    else
      return (one/ two.to_f ).round(3)
    end
  end

  def state_operate_able content
    on = link_to "正常", state_operate_manage_adv_content_path(content, state: "on")
    trash = link_to "放入回收站", state_operate_manage_adv_content_path(content, state: "trash")
    deleted  = link_to "下线", state_operate_manage_adv_content_path(content, state: "deleted")
    if content.trash
      [on, deleted]
    elsif content.deleted
      [on, trash]
    else
      [trash, deleted]
    end
  end

end
