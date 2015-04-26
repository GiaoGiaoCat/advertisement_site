module UserRelationship
  extend ActiveSupport::Concern

  included do
    has_one :profile, foreign_key: "user_id"
    has_many :applications, foreign_key: "user_id"
    has_many :orders, :through => :applications
    has_many :payments, foreign_key: "user_id"
    has_many :channels, foreign_key: "user_id"
    has_many :rules, through: :channels

    scope :developers, -> { where(role: "developer") }
    scope :spreaders, -> { where(role: "spreader") }
    scope :channel_managers, -> { where(role: "channel_manager") }
  end

  module ClassMethods
  end

  module InstanceMethods
  end
end
