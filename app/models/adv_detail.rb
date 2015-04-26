class AdvDetail< ActiveRecord::Base
  # extends ...................................................................
  belongs_to :adv_content
  validates_presence_of :balance_cycle, :balance_requirement, :promotion_requirement, :manage_site, :manage_site_user, :manage_site_password, :balance_first_date, :company, :name, :phone

  before_create :turn_date_str, :phone_qq_confirm
 after_save :update_adv_content_notify, if: Proc.new { |detail| detail.balance_cycle_changed? || detail.balance_first_date_changed?}
  # after_save :update_adv_content_notify, if: :balance_cycle_changed?
  # after_save :update_adv_content_notify, if: :balance_first_date_changed?

  def update_adv_content_notify
    #检测是否存在 没有过任何账单信息
    unless self.adv_content.account_bill_infos.reorder("end_date DESC").first.nil?
      #如果更改首次结算时间时候，的动作
     end_date = self.adv_content.account_bill_infos.reorder("end_date DESC").first.end_date

      if balance_first_date.to_date > end_date
         notifies = self.adv_content.adv_content_account_notifies.where("start_date >= ?", end_date)
         notifies.delete_all
      end
     #如果更改的为结账周期，删除最后一个提醒之后的所有提醒，重建提醒
     notifies = self.adv_content.adv_content_account_notifies.where("start_date >= ?", end_date)
     unless notifies.count.zero?
      notifies.delete_all
      i_start_date = end_date
      infer_date = self.balance_cycle.to_i
      i_end_date = infer_date.days.from_now(i_start_date)
        while (i_end_date < Date.today)
          self.adv_content.adv_content_account_notifies.create(start_date: i_start_date, end_date: i_end_date)
          i_start_date = i_end_date
          i_end_date = infer_date.days.from_now(i_start_date)
        end
      end
    else
      #检测是否存在 没有过任何账单信息 可以删除所有账单
      self.adv_content.adv_content_account_notifies.delete_all
     AdvContent.where.not(deleted: true).each {|item| item.for_account_notify}
     AdvContent.where.not(deleted: true).each {|item| item.for_account_notify}
    end

  end


  def turn_date_str
    self.balance_first_date = self.balance_first_date.to_s
  end

  def phone_qq_confirm
    reg = Regexp.new('[a-z]')
    if   reg.match(self.qq) || reg.match(self.phone)
    return false
    end
  end
end
