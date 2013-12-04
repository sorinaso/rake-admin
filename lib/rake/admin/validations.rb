require 'rake/admin/error'

module Rake
  module Admin
    module Validations
      def validate_not_nil(value, msg)
        raise Rake::Admin::TaskConfigurationError.new(msg) if value.nil?
      end
    end
  end
end