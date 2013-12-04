require 'rake/tasklib'

module Rake
  module Admin
    module VirtualBox
      class Remote < Rake::TaskLib
        attr_accessor :local_disk_path, :remote_disk_path,
                      :remote_ssh_user, :remote_hostname

        def initialize
          yield self if block_given?
          raise "must define local disk path" if @local_disk_path.nil?
          raise "must define remote disk path" if @remote_disk_path.nil?
          raise "must define remote hostname" if @remote_hostname.nil?
          raise "must define the remote ssh user" if @remote_ssh_user.nil?

          # VM disk source(local disk path).
          @disk_src = "#{@remote_ssh_user}@#{@remote_hostname}:'#{@remote_disk_path}'"

          # VM disk destination(remote ssh disk path).
          @disk_dst = "#{@local_disk_path}"

          define
        end

        def define
          namespace :disk do
            desc "Get virtualbox disk from '#{@disk_src}' to #{@disk_dst}"
            task :get do
              sh "rsync -avziP --inplace --checksum #{@disk_src} #{@disk_dst}"
            end
          end
        end
      end
    end
  end
end
