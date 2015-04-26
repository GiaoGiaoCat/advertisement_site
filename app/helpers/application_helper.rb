# encoding: utf-8
module ApplicationHelper
  def show_cell(obj, attr, options = {})
    content = content_tag(:th, options[:label] || attr.humanize, class: 'span3 text_right') + content_tag(:td, obj.attributes[attr])
    content_tag(:tr, content)
  end

  def show_user_avatar
    if current_user.role?(:admin)
      "admin_avatar.jpg"
    else
      "developer_avatar.jpg"
    end
  end

  # Helper for Genyx Theme
  def side_nav_with_li(text, class_name, url, notification = nil)
    li_class = if url.include?("admin=true")
      # Take a look at nav_class_with_urls method comment.
      url.include?(request.path) && url.include?("admin=true") ? 'current' : ''
    elsif url.include?("admin=false")
      url.include?(request.path) && url.include?("admin=false") ? 'current' : ''
    else
      current_page?(url) ? 'current' : ''
    end
    content_tag(:li, side_nav_without_li(text, class_name, url, notification), class: li_class)
  end

  def side_nav_without_li(text, class_name, url, notification = nil)
    li_class = 'icon20 ' + class_name
    notification_text = ""
    notification_text = content_tag(:span, notification, class: 'notification green') if notification != nil
    link_to(content_tag(:span, content_tag(:i, nil, class: li_class), class:'icon') + content_tag(:span, text, class: 'txt') + notification_text, url)
  end

  def nav_class_with_urls(urls = [], admin_mode = false)
    li_class = ""
    urls.each do |url|
      if admin_mode == "true"
        # Why current_page? method not working.
        # when we visit a url with params,
        # current url will be looks like /manage/charts/channel_view?utf8=✓&admin=true
        # but url is /manage/charts/channel_view?admin=true
        # so current_page?(url) will be return false.
        li_class = 'current' if url.include?(request.path) && url.include?("admin=true")
      else
        li_class = 'current' if current_page?(url)
      end
    end
    li_class
  end

  # Helper for Devise Layout
  def data_active_for_devise_layout
    if current_page?(new_user_session_path) || controller.controller_name == "sessions"
      "log"
    elsif current_page?(new_user_registration_path) || controller.controller_name == "registrations"
      "reg"
    elsif current_page?(new_user_password_path) || controller.controller_name == "passwords"
      "forgot"
    else
      "blank"
    end
  end

  def draw_color_for_app(app)
    if app.adv_warning > 0
      return "warning"
    elsif app.display_advertising
      return 'active'
    end
  end

  def link_to_with_date name, options, html_options
    options << "?end=#{params[:end]}&begin=#{params[:begin]}"
    link_to name, options, html_options
  end
end
