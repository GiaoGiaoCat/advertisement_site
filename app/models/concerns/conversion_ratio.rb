module ConversionRatio
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    private
      def get_ratio(ratio_settings, created_at)
        ratio = 1
        ratio_settings.each do |setting|
          ratio = setting[0] if setting[1].to_date <= created_at.to_date
        end
        ratio
      end
  end

  module InstanceMethods
  end
end
