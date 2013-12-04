require 'rake/tasklib'

module Rake
  module Admin
    module Puppet
      module Master
        class Remote < Rake::TaskLib
          attr_accessor :local_directory, :remote_directory,
                        :remote_ssh_user, :remote_hostname, :local_excludes

          def initialize
            yield self if block_given?
            raise "must define puppet local path" if @local_directory.nil?
            raise "must define puppet remote path" if @remote_directory.nil?
            raise "must define remote hostname" if @remote_hostname.nil?
            raise "must give the remote ssh user" if @remote_ssh_user.nil?

            # Excludes.
            @local_excludes ||= []

            # Puppet source(local directory)
            @puppet_src = "#{@local_directory}/."

            # Puppet destination(ssh directory)
            @puppet_dst = "#{@remote_ssh_user}@#{@remote_hostname}:'#{@remote_directory}/.'"

            define
          end

          def define
            desc "Deploy puppet from '#{@puppet_src}' to #{@puppet_dst}"
            task :deploy do
              sh rsync_to_puppetmaster_cmd(true)
              sh rsync_to_puppetmaster_cmd
            end

            desc "Restart puppetmaster service on #{@remote_ssh_user}@#{@remote_hostname}"
            task :restart do
              sh "ssh root@#{@remote_hostname}   service puppetmaster restart"
            end

            desc "List puppetmaster certificates on #{@remote_ssh_user}@#{@remote_hostname}"
            task :cert_list do
              sh "ssh root@#{@remote_hostname} puppet cert list"
            end

            desc "Sign puppetmaster certificate for host on #{@remote_ssh_user}@#{@remote_hostname}"
            task :cert_sign, :host do
              sh "ssh root@#{@remote_hostname} puppet cert sign #{args[:host]}"
            end

            desc "Clean puppetmaster certificate for host on #{@remote_ssh_user}@#{@remote_hostname}"
            task :cert_clean, :host do
              sh "ssh root@#{@remote_hostname} puppet cert clean #{args[:host]}"
            end
          end

          private
          def rsync_to_puppetmaster_cmd(dry_run=false)
            params = " -avzPiL --delete"
            @local_excludes.each { |exclude| params << " --exclude #{exclude}"}
            params << " --dry-run" if dry_run
            "rsync#{params} #{@puppet_src} #{@puppet_dst}"
          end
        end
      end
    end
  end
end
