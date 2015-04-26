# encoding: utf-8
module Manage::AccountBillsHelper

  def operate_label_array(account_bill)
    result = []
    if current_user.role?(:finance)
      if account_bill.state.to_i != AccountBill::STOP_WAIT_TO_PAY
        if (account_bill.invoice_state == AccountBill::INVOICE_NEDD_NOT_PAY )
          result << link_to("对方已收发票", payed_invoice_manage_account_bill_path(account_bill), class: 'btn btn-info')
        elsif account_bill.state.to_i == AccountBill::COMMERCE_CONFIRME
          result << link_to("确认已付款到帐", change_state_manage_account_bill_path(account_bill, state: AccountBill::FINANCE_CONFIRME), class: 'btn btn-success')
          result << link_to("财务确认-账单与到帐金额不一致", change_state_manage_account_bill_path(account_bill, state: AccountBill::UN_CHECKED), class: 'btn btn-warning')
        elsif account_bill.state.to_i == AccountBill::STOP_WAIT_TO_PAY
          result << link_to("财务确认-坏账", change_state_manage_account_bill_path(account_bill, state: AccountBill::BAD_DEBTS), class: 'btn btn-danger')
        end
      else
        result << link_to("财务确认-坏账", change_state_manage_account_bill_path(account_bill, state: AccountBill::BAD_DEBTS), class: 'btn btn-danger')
      end
    elsif current_user.role?(:channel_manager)
        # binding.prykkkkkk
      if account_bill.state.to_i != AccountBill::STOP_WAIT_TO_PAY
        if account_bill.state.to_i == AccountBill::CHECKED
          result << (link_to '上传打款截图', add_image_manage_account_bill_path(account_bill), class: 'btn btn-default')
          result << (link_to content_tag(:i, nil, class:'icon12 i-pencil') + '编辑账单', edit_manage_account_bill_path(account_bill), class: 'btn btn-default')
        end
        if account_bill.unchecked?
          result << (link_to '对账确认', edit_manage_account_bill_path(account_bill), class: 'btn btn-default', remote: true)
          result << (link_to '添加账单详细', new_manage_account_bill_account_bill_info_path(account_bill), class: 'btn btn-default')
          result << (link_to '编辑账单', edit_manage_account_bill_path(account_bill), class: 'btn btn-default')
          result << (link_to "删除此账单", manage_account_bill_path(account_bill), method: :delete, class: 'btn btn-danger')
        end
      end
    elsif current_user.role?(:admin)
      result << (link_to " 编辑此账单", update_all_manage_account_bill_path(account_bill), class: 'btn btn-danger')
    end
    result << (link_to "查看", manage_account_bill_path(account_bill), class: 'btn btn-default')
  end

  def option_for_search(user)
    option = AccountBill::user_search_params_permit(user)

    hash = Hash.new
    hash["全部"] = "0"
    hash.merge! AccountBill::STATE.select{|key, value|  option.include?(value.to_i) } unless option.nil?
    return hash
  end

  def select_lable_to_condition(label)
    case label
      when "全部"
        {}
      when "未核对"
        {checked: false}
      when "核对"
        {checked: true}
      when "已发发票"
        {invoice: true}
      when "未发发票"
        {invoice: false}
      when "已支付"
        {payed: true}
      when "未支付"
        {payed: false}
       else
        {}
      end
  end


  def cache_key_for_account_bills
    begin_day = params[:begin]
    end_day = params[:end]
    "#{begin_day},#{end_day}"
  end

end
