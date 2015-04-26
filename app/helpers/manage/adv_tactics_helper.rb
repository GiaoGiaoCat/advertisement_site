# encoding: utf-8
module Manage::AdvTacticsHelper
  def show_notice_type type
    AdvTactic::NOTICE_TYPES[type.to_i - 1][0] rescue "未知错误"
  end

  def show_adv_content ads
    ad = AdvContent.where(id: ads)
    ad.collect(&:title).join(", ")
    # ad.present? ? ad.title : "随机"
  end

  def show_tatics_channel adv_tatics
    adv_contents = String.new
    adv_tatics.adv_content_ids.each do |item|
      infer = AdvContent.find_by_id(item)
      adv_contents << infer.title unless infer.nil?
    end
    return adv_contents
  end

  def turn_adv_content_ids arr
    result = []
    arr.each do |item|
      adv_content = AdvContent.find_by_id(item)
      result << adv_content unless adv_content.nil?
    end
    return result
  end

  def paratition_adv_contents adv_tatic, adv_contents
    adv_contents.partition do |content|
      adv_tatic.adv_content_ids.include? content.id unless  adv_tatic.adv_content_ids.nil?
    end
  end
end
