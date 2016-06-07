module Rake
  module Admin
    module Spec
      def self.resources_path
        ret = File.join("/tmp", "rake-admin-tests")

        Dir.mkdir(ret) unless File.exists?(ret)

        ret
      end
    end
  end
end