  require 'rake/tasklib'
require 'net/ssh'

module Rake
  module Admin
    module Vagrant
      class Local < Rake::TaskLib
        attr_accessor :vm_name, :box_path

        def initialize
          yield self if block_given?
          raise "must define the vm_name paramater" if @vm_name.nil?
          @box_path ||= "."
          @box_file = File.join(@box_path, "#{@vm_name}.box")

          define
        end

        def define
          desc "Start the #{@vm_name} VM"
          task :up do
            sh "VBoxManage list runningvms |grep #{@vm_name} || vagrant up #{@vm_name} --no-provision "
          end

          desc "Execute the provisioner for #{@vm_name} VM"
          task :provision => [:up] do
            sh "vagrant provision #{@vm_name}"
          end

          desc "Destroy the #{@vm_name} VM"
          task :destroy do
            sh "vagrant destroy #{@vm_name} -f"
          end

          desc "Reload the #{@vm_name} VM"
          task :reload do
            sh "vagrant reload #{@vm_name}"
          end

          desc "Destroy and up the #{@vm_name} VM"
          task :recreate => [:destroy, :provision]

          desc "Package #{@vm_name} VM into #{@box_file}"
          task :package do
            sh "vagrant package #{@vm_name} --output #{@box_file}"
          end

          desc "SSH to the #{@vm_name} VM"
          task :ssh => [:up] do
            sh "vagrant ssh #{@vm_name}"
          end

          desc "Halt the #{@vm_name} VM"
          task :halt do
            sh "vagrant halt #{@vm_name}"
          end
        end
      end
    end
  end
end
