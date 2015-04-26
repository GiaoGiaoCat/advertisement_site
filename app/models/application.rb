class Application < ActiveRecord::Base
  # extends ...................................................................
  # includes ..................................................................
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
  belongs_to :user
  has_many :orders
  has_many :reports, class_name: "AdvApplicationReport"
  has_many :adv_settings
  has_many :adv_tactics ,through: :adv_settings,  dependent: :destroy
  has_many :statistics, class_name: "AdvStatistic"
  has_and_belongs_to_many :rules
  has_and_belongs_to_many :adv_contents
  attr_accessor :adv_contents_params, :adv_warning
  # validations ...............................................................
  validates :name, :presence => true, :uniqueness => true
  validates :platform, :presence => true
  validates :description, :presence => true
  validates :api_key, :presence => true, :uniqueness => true, :length => { :is => 8 }, :on => :save
  validates :secret_key, :presence => true, :uniqueness => true, :length => { :is => 32 }, :on => :save
  # callbacks .................................................................
  scope :ordered_by_view_count, -> {
    select("applications.*, SUM(`adv_statistics`.`view_count`) AS statistics_view_count")
    .joins(:statistics)
    .group("application_id")
    .order("statistics_view_count DESC")
  }
  scope :display_advertising, -> { where(display_advertising: 0) }
  scope :play_advertising, -> { where(display_advertising: 1) }
  # scopes ....................................................................
  # additional config .........................................................
  encrypted_id key: 'VUUZzOQXNwx8HuyD'
  after_initialize :set_default_platform, if: 'new_record?'
  before_create :generate_key

  def adv_contents_to_label
    app = String.new
    adv_contents = self.get_adv_contents
    # BUG: 这里会把APP关联的广告物料都清空
    # self.adv_contents = adv_contents
    adv_contents.each do |content|
      app << "#{content.title}: " if content.activity
    end
    return app
  end

  def have_adv_content?
    if self.get_adv_contents.size != 0
      return true
    end
  end

  def get_adv_contents
    ids = []
      self.adv_tactics.each do |item|
        item.adv_content_ids.each do |id|
         ids << id
        end
      end
    ids.uniq!
    return AdvContent.where(id: ids)
  end

  def has_adv_content?(adv_content_id)
    flag = self.adv_tactics.find_index do |tactic|
      tactic.adv_content_ids.include? adv_content_id
    end
    return flag
  end

  def adv_warning
    @adv_warning.nil? ? 0: @adv_warning
  end


  # class methods .............................................................
  # public instance methods ...................................................
  # protected instance methods ................................................
  # private instance methods ..................................................
  private

  def set_default_platform
    self.platform ||= 1
  end

  def generate_key
    base_secret_key = Time.now.to_i.to_s
    begin_num = Random.rand(24)
    self.api_key = Digest::MD5.hexdigest(self.name + base_secret_key)[begin_num, 8]
    # SecureRandom.hex generates a random hex string. it's a new method need ruby 1.9.3+
    self.secret_key = SecureRandom.hex
  end
end
