class AdvContentAccountNotify < ActiveRecord::Base
  # extends ...................................................................
  belongs_to :adv_content
  default_scope ->{order("end_date DESC")}

  def to_lable
    "#{self.adv_content.tag}  : #{self.start_date} - #{self.end_date}"
  end
end
