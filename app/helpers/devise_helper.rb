module DeviseHelper
  # A simple way to show error messages for the current devise resource. If you need
  # to customize this method, you can either overwrite it in your application helpers or
  # copy the views to your application.
  #
  # This method is intended to stay simple and it is unlikely that we are going to change
  # it to add more behavior or options.
  def devise_error_messages!
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      :count => resource.errors.count,
                      :resource => resource.class.model_name.human.downcase)

    html = <<-HTML
    <div id="error_explanation" class="alert alert-error">
      <button class="close" data-dismiss="alert" type="button">x</button>
      <strong>#{sentence}</strong>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  def devise_error_messages?
    resource.errors.empty? ? false : true
  end

  def show_flash_messages
    return if flash.blank?
    flash.each do |key, value|
      content = content_tag(:button, "x", class: 'close', "data-dismiss" => 'alert')
      # content += content_tag(:strong, content_tag(:i, nil, class: 'icon24 i-close-4') + "Oh snap!")
      content += value
      class_name = key == "notice" ? "alert alert-success" : "alert alert-error"
      return content_tag(:div, content, class: class_name)
      # "#{key} #{value}"
    end
  end

end
