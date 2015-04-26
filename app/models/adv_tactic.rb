# encoding: UTF-8
class AdvTactic < ActiveRecord::Base
  belongs_to :adv_setting
  validates_presence_of :action, :value, :notice_type

  serialize :adv_content_ids

  after_save :adv_content_relate_operate

  NOTICE_TYPES = [["通知栏", 1], ["桌面文件夹", 2], ["桌面弹窗", 3], ["通知栏 - 微信招商", 4]]
  ACTION_TYPES = [
    ['首次打开应用', 'open_app'],
    ['定时弹出', 'time_triggered'],
    ['指定条件', 'open_activity'],
    ['退出应用', 'quit_app'],
    ['悄悄话', 'listing_topics'],
    ['广告墙', 'wall']
  ]

  def adv_content_relate_operate
    ids = self[:adv_content_ids]
    ids.each do |id|
     content =  AdvContent.find_by_id(id)
     content.update_attributes(activity: true)  unless  content.nil?
    end
  end

 #删除所有的广告关联
  def self.del_adv_contents(adv_content_id)
    AdvTactic.all.each do |tactic|
      tactic.del_adv_content adv_content_id
    end
  end

  def self.assgin_adv_content(adv_content_id)
    self.all.each { |tactic| tactic.assgin_adv_content(adv_content_id) }
  end

  def assgin_adv_content(adv_content_id)
    ids = []
    ids << self[:adv_content_ids] << adv_content_id
    self[:adv_content_ids] = ids.flatten.uniq
    self.save
  end

  #删除数组里的关联
  def del_adv_content(adv_content_id)
    unless self[:adv_content_ids].nil?
      ids = self[:adv_content_ids]
      ids.delete_if { |item| item.to_i == adv_content_id.to_i }
      self[:adv_content_ids] = ids.flatten.uniq
      self.save
    end
  end

  def should_be_sort?
     self.action == "wall"
  end

  def adv_content_ids
    self[:adv_content_ids].map { |id| id.to_i } if self[:adv_content_ids]
  end

  def adv_content_ids= content_ids
    self[:adv_content_ids] = content_ids.flatten.uniq
  end

  def calculate_all_actual_view_count
    AdvContent.calculate_actual_view_count
  end

  def to_label_with_notify
    str = to_label
    unless self.notice_type.nil?
        NOTICE_TYPES.each do |item|
       str << "-----#{item[0]}" if  item[1] == self.notice_type.to_i
        end
     end
     str
 end

  def to_label
    case action
    when "open_app"
      "打开应用#{value}秒后"
    when "time_triggered"
      "#{value}定时打开"
    when "open_activity"
      "#{value}事件发生时"
    when "quit_app"
      "退出应用#{value}秒后"
    when "listing_topics"
      "每隔#{value}条帖子"
    when "wall"
      "广告墙"
    end
  end
end
