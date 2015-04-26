# encoding: utf-8
module Manage::ChannelsHelper
  def show_enabled_status(status)
    class_name = "badge "
    class_name += status ? "badge-success" : "badge-warning"
    text = status ? "启用" : "停用"
    content_tag(:span, text, class: class_name)
  end
end
