module Manage::ApplicationsHelper
  def show_platform_name(platform = 1, name = false )
    case platform
    when 1
      content_tag(:i, nil, class: 'icon16 i-android') + (name ? "Android" : nil)
    when 2
      content_tag(:i, nil, class: 'icon16 i-apple') + (name ? "IOS" : nil)
    end
  end

  def application_report_label app
     reports = app.reports.where(created_at: 1.days.ago(Date.today).beginning_of_day..Date.today.end_of_day)
     warning = 0
      reports.each do |item|
      warning += item.warning_count
    end
    result = String.new
    if warning != 0
        result << "无广告预警次数：#{warning}"
     end
   return result
  end

  def have_default_channel?(settings)
    return settings.find_index{|setting| setting.channel ==  "默认渠道"}
  end
end
