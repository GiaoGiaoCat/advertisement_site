class AdvContent < ActiveRecord::Base
  # extends ...................................................................
  # includes ..................................................................
  # relationships .............................................................

  has_one :adv_detail, dependent: :destroy
  has_many :adv_statistics
  has_many :account_bill_infos
  has_many :platform_statistics
  has_many :adv_advertiser_reports
  has_many :adv_content_account_notifies, dependent: :destroy

  belongs_to :user
  has_and_belongs_to_many :applications
  attr_accessor :adv_setting_name, :relate_params, :income, :cp_report, :total_install_count
  # validations ...............................................................
  validates_presence_of :title, :price, :description, :icon, :banner, :square_banner
  validates_presence_of :url, :apk_sign, if: Proc.new { |c| c.website.blank? }
  validates_numericality_of :plan_view_count, :price
  validates_uniqueness_of :title, scope: :tag
  validates :version_code, numericality: { only_integer: true, greater_than: 0}
  validates :version_name, presence: true

  #upload some image
  mount_uploader :icon, MaterialUploader
  mount_uploader :url, MaterialUploader
  mount_uploader :banner, MaterialUploader
  mount_uploader :square_banner, MaterialUploader
  STATE = {" 正常" => :on, "回收站" => :trash, "删除" =>  :deleted}

  # callbacks .................................................................
  # after_create :calculate_all_actual_view_count
  # after_destroy :calculate_all_actual_view_count
  # after_update :calculate_all_actual_view_count
  # # scopes ....................................................................


  scope :between, ->(d1, d2) {
    where(created_at: Date.parse(d1)...Date.parse(d2).tomorrow)
  }
  scope :trash_between, ->(d1, d2) {
    where(updated_at: Date.parse(d1)...Date.parse(d2).tomorrow)
  }
  scope :activity, -> { where(activity: true) }
  scope :in_trash, -> { where(trash: true) }
  scope :not_in_trash, -> { where(deleted: false) }

  scope :un_invoice, -> { joins(:adv_detail).where("adv_details.balance_first_date < ?", Date.today) }



  def self.in_state i_state
    case i_state
      when "on"
        self.where("deleted = ? AND trash = ?", false, false)
      when "trash"
        self.where("trash = ?", true, )
      when "deleted"
        self.where("deleted = ?", true)
    end
  end

  def self.account_bills_notify
    adv_contents  = AdvContent.all.select {|adv_content|  adv_content.adv_content_account_notifies.count > 0}
  end

  def self.account_bills_notify_count
    self.account_bills_notify.count
  end
  # .where(adv_detail: {"balance_first_date > ?", Date.today})
  # additional config (i.e. accepts_nested_attribute_for etc...) ..............
  encrypted_id key: 'higUduxc8dL9qJvV'

  # mount_uploader :icon, MaterialUploader
  # mount_uploader :url, MaterialUploader
  # mount_uploader :banner, MaterialUploader
  # mount_uploader :square_banner, MaterialUploader
  # class methods .............................................................

  def cp_report_num d1, d2
    reports = self.adv_advertiser_reports.between(d1, d2)
    cp_report = reports.sum(:count)
  end

  def cp_report_num_to_lable d1, d2
   reports = self.adv_advertiser_reports.between(d1, d2)
    diff_day = (Date.parse(d2)  - Date.parse(d1)).to_i + 1
    if diff_day > 0 && diff_day != reports.size
     return "warning"
    end
  end

  def should_have_cp_report? d1, d2
    days = (Date.parse(d1)..Date.parse(d2)).select {|day| self.adv_statistics.by_day(day).size > 0}
    if self.adv_advertiser_reports.where(report_date: days).size != days.size
      'warning'
    end
  end

  def cp_report_days d1, d2
    reports = self.adv_advertiser_reports.between(d1, d2)
    report_days = reports.map {|report| report.report_date}
  end

  def platform_adv_statistics_sum(d1, d2)
    self.platform_statistics.between(d1, d2).sum(:install_count)
  end

  def platform_adv_statistics_sum_in_days(days)
    self.platform_statistics.where(report_date: days).sum(:install_count)
  end

  def self.calculate_actual_view_count
    all.each { |ad| ad.calculate_actual_view_count }
  end

  def self.reset_today_view_count
    all.each { |ad| ad.update_column(:today_view_count, 0) }
  end
  # public instance methods ...................................................
  def income_level(statistics = nil)
    statistics ||= AdvStatistic.by_days(7).by_advertisement(id)
    income = price * statistics.sum(:install_count) / statistics.sum(:view_count)
    income.nan? ? 0 : rount_to_money(income)
  end

  def calculate_all_actual_view_count
    AdvContent.calculate_actual_view_count
  end

  def calculate_actual_view_count
    unless AdvTactic.count == 0
      actual_view_number = plan_view_count / AdvTactic.count * AdvContent.activity.count
      update_column(:actual_view_count, actual_view_number)
    end
  end
  # protected instance methods ................................................
  # private instance methods ..................................................
   def day_statistics
    statistics =
      AdvStatistic.by_advertisement(id).today
    [statistics.sum(:read_count), statistics.sum(:view_count), statistics.sum(:click_count), statistics.sum(:install_count)]
  end

  def yesterday_statistics
     yesterday =
      AdvStatistic.by_advertisement(id).by_days(2)
    [statistics.sum(:read_count), statistics.sum(:view_count), statistics.sum(:click_count), statistics.sum(:install_count)]
    today =
     AdvStatistic.by_advertisement(id).today
    [statistics.sum(:read_count), statistics.sum(:view_count), statistics.sum(:click_count), statistics.sum(:install_count)]
    result = []
    yesterday.zip(today) do |x, y|
      result << x - y
    end
    return result
  end

  def week_statistics
    statistics =
      AdvStatistic.by_advertisement(id).by_days(7)
    [statistics.sum(:read_count), statistics.sum(:view_count), statistics.sum(:click_count), statistics.sum(:install_count)]
  end

  def month_statistics
    statistics =
      AdvStatistic.by_advertisement(id).by_days(30)
    [statistics.sum(:read_count), statistics.sum(:view_count), statistics.sum(:click_count), statistics.sum(:install_count)]
  end

  def show_statistics(type)
    index = [:read ,:view, :click, :install].find_index(type)
    "#{day_statistics[index]}/#{day_statistics[index]}/#{week_statistics[index]}/#{month_statistics[index]}"
  end

  def yesterday_data kind
    yes_statistics = AdvStatistic.by_advertisement(id).by_days(1)
    today_statistics = AdvStatistic.by_advertisement(id).today
    yes_count =  [yes_statistics.sum(:read_count), yes_statistics.sum(:view_count), yes_statistics.sum(:click_count), yes_statistics.sum(:install_count)]
    today_count =  [yes_statistics.sum(:read_count), yes_statistics.sum(:view_count), yes_statistics.sum(:click_count), yes_statistics.sum(:install_count)]
    result = []
    yes_count.zip(today_count) do |x, y|
      result << x - y
    end
    case kind
    when "read_count"
      result[0]
    when "view_count"
      result[1]
    when "click_count"
      result[2]
    when "install_count"
      result[3]
    end
  end

  def yesterday_click_count
     statistics = AdvStatistic.by_advertisement(id).by_days(1)
    return statistics.sum(:click_count)
  end

  def self.make_count_of_number(arr)
    couter  = []
    arr.each do |item|
      couter << item.split("/")
    end
    result = [0, 0, 0, 0]
    couter.each do |item|
      item.each_with_index do |num, i|
        result[i] += num.to_i
      end
    end
    return result.join("/")
  end

  def platforms
    Platform.all.select{|platform| platform.adv_content_ids.include? self.id}
  end

  #很重要的逻辑
  def notify_start_date
    notify = self.adv_content_account_notifies.reorder("end_date DESC").first
    bill_info = self.account_bill_infos.reorder("end_date DESC").first

    #逻辑  1付初值， 主要为， 先查看 notify 通知类型的end_date 2,比较是否有更靠前的账单信息结束日期  3：都不存在的话，查看广告的首次结算日期
    start_date ||= notify.end_date if notify

    if bill_info
      if start_date.nil?
        start_date = bill_info.end_date
      else
        start_date = bill_info.end_date if bill_info.end_date > start_date
      end
    end

    start_date ||= Date.today
  end

  def  first_account_notify
    if (infer = self.account_bill_infos.reorder("end_date DESC").last)
      i_start_date = 1.days.from_now(infer.end_date)
    end
    if  (infer = self.adv_statistics.reorder("created_at").first)
      i_start_date ||=  infer.created_at.to_date
    end

    i_start_date ||= self.created_at.to_date
    end_date = self.adv_detail.nil? ? 1.days.ago(Date.today) : Date.parse(self.adv_detail.balance_first_date)

    unless self.account_bill_infos.first.nil?
      if end_date < self.account_bill_infos.reorder("end_date DESC").first.end_date
          end_date = self.adv_detail.balance_cycle.to_i.days.from_now i_start_date
       end
    end

    if end_date < Date.today
      self.adv_content_account_notifies.create(start_date: i_start_date, end_date: end_date)
    end

  end

  def first_account_notify_date
    end_date = self.adv_detail.nil? ? 1.days.ago(Date.today) : Date.parse(self.adv_detail.balance_first_date)
  end

  def for_account_notify
    if (first_account_notify_date < Date.today) && self.adv_content_account_notifies.reorder("end_date DESC").size.zero?
      first_account_notify
    else
      start_date = notify_start_date
      infer_date = self.adv_detail.nil? ? 10 : self.adv_detail.balance_cycle.to_i
      i_start_date = 1.days.from_now start_date
      i_end_date = infer_date.days.from_now(i_start_date)
      while (i_end_date < Date.today)
        unless self.adv_statistics.between(i_start_date.to_s, i_end_date.to_s).size.zero?
          self.adv_content_account_notifies.create(start_date: i_start_date, end_date: i_end_date)
        end
         i_start_date =  1.days.from_now i_end_date
        i_end_date = infer_date.days.from_now(i_start_date)
      end
    end

  end

  def account_notify_changes(start_date, end_date)

    no_use_notifies  = self.adv_content_account_notifies.where("start_date >= ? AND end_date <= ?", start_date, end_date)
    self.adv_content_account_notifies.destroy no_use_notifies
    left_notify = self.adv_content_account_notifies.where("start_date < ?", start_date).reorder("end_date DESC").first
    right_notifies = self.adv_content_account_notifies.where("start_date > ?", start_date).reorder("end_date DESC")

    left_notify.update_column(:end_date, start_date.yesterday ) unless left_notify.nil?
    right_notifies.first.update_column(:start_date,  end_date.tomorrow) unless right_notifies.count.zero?

    infer_date = self.adv_detail.nil? ? 10 : self.adv_detail.balance_cycle.to_i

    #更新所有的提醒日期在，新创建的账单为最新时候
    if self.account_bill_infos.where("start_date > ? ", end_date).count.zero?
      self.adv_content_account_notifies.destroy right_notifies
      i_start_date = 1.days.from_now end_date
      i_end_date = infer_date.days.from_now(i_start_date)
      while (i_end_date < Date.today)
        self.adv_content_account_notifies.create(start_date: i_start_date, end_date: i_end_date)
        i_start_date =  1.days.from_now i_end_date
        i_end_date = infer_date.days.from_now(i_start_date)
      end
    end
  end

  private
  def rount_to_money(n)
    (n * 100).round / 100.0
  end
end
