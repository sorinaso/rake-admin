module Rake
  module Admin
    module Spec
      def self.resources_path
        File.join(File.dirname(__FILE__), "resources")
      end
    end
  end
end