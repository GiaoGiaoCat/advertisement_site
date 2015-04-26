# encoding: utf-8
module Manage::PlatformAccountsHelper
  def draw_color_for_platform_account(d1, d2, account)
    diff_day = (Date.parse(d2)  - Date.parse(d1)).to_i + 1
    accounts_size =  account.platform_balanceios.between(d1, d2).group("adv_content_id").count
    if accounts_size.size == 0 || accounts_size.select{|key, value| value != diff_day}.size > 0
     return "warning"
    end
  end

end
