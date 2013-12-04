require 'rake/tasklib'
require 'net/ssh'
require 'log4r'

module Rake
  module Admin
    module Puppet
      module Client
        class Remote < Rake::TaskLib
          attr_accessor :remote_ssh_user, :remote_hostname, :puppetmaster_host, :puppet_path

          def initialize
            yield self if block_given?
            raise "must define remote hostname" if @remote_hostname.nil?
            raise "must define the remote ssh user" if @remote_ssh_user.nil?
            raise "must define the puppet master host" if @puppetmaster_host.nil?
            raise "must define the puppet remote path" if @puppet_path.nil?

            @logger = Log4r::Logger.new('rake:admin:puppet:client:remote')
            @logger.outputters = Log4r::Outputter.stdout

            define
          end

          def define
            desc "Executes puppet --noop on #{@remote_hostname}"
            task :noop do
              tunnel_cmd "puppet agent --test --noop --server #{@puppetmaster_host}"
            end

            desc "Executes puppet on #{@remote_hostname}"
            task :apply do
              tunnel_cmd "puppet agent --test --server #{@puppetmaster_host}"
            end

            desc "Clean all certificates."
            task :cert_clean do
              ssh_cmd "find #{@puppet_path} -name '*.pem' -delete"
            end

            desc "SSH to host with tunnel"
            task :tunnel do
              sh "ssh -R 8140:localhost:8140 #{@remote_ssh_user}@#{@remote_hostname}"
            end

            desc "Test the SSH"
            task :tunnel_test do
              tunnel_cmd "openssl s_client -connect #{@puppetmaster_host}:8140"
            end
          end

          private
          def tunnel_cmd(cmd)
            sh "ssh -R 8140:localhost:8140 #{@remote_ssh_user}@#{@remote_hostname} '#{cmd}'"
          end

          def ssh
            if @session.nil?
              @logger.info("Connecting to #{@remote_ssh_user}@#{@remote_hostname}")
              @session = Net::SSH.start(@remote_hostname, @remote_ssh_user)
            end

            @session
          end

          def ssh_cmd(cmd)
            puts "[#{@remote_ssh_user}@#{@remote_hostname}] cmd: #{cmd}"
            puts ssh.exec! cmd
          end
        end
      end
    end
  end
end