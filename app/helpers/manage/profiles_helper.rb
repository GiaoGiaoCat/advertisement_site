# encoding: utf-8
module Manage::ProfilesHelper
  def show_profile_type_name(type_name = "individual")
    case type_name
    when "individual"
      "个人帐号"
    when "company"
      "企业帐号"
    end
  end

  def show_profile_label_by_type(type_name = "individual", field = "name")
    case field.to_sym
    when :name
      type_name == "individual" ? "开发者姓名" : "公司全名"
    when :identity_card
      type_name == "individual" ? "身份证号码" : "营业执照编号"
    when :bank_account_name
      type_name == "individual" ? "开户人姓名" : "银行开户名称"
    end
  end
end
