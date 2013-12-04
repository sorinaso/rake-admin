require 'log4r'

module Rake
  module Admin
    module Utils
      module SSH
        def self.ssh_session(url, verbosity = Logger::INFO)
          username, hostname = url.split("@")
          SSHHelper.new(hostname, username, verbosity)
        end

        class SSHHelper
          # Starts SSH session
          def initialize(hostname, username, verbosity = Logger::INFO)
            @username = username
            @hostname = hostname

            if logger.nil?
              @logger = Log4r::Logger.new("ssh[#{@username}@#{@hostname}]")
              @logger.outputters = Log4r::Outputter.stdout
            else
              @logger = logger
            end

            @logger.info("Connecting...")
            @session = Net::SSH.start(@hostname, @username, :verbose => @verbosity)
          end

          # Execute SSH command.
          def cmd(cmd)
            stdout = ""
            stderr = ""
            exit_code = nil
            exit_signal = nil

            logger.info("cmd: #{cmd}")

            @session.open_channel do |channel|
              channel.exec(cmd) do |ch, success|
                unless success
                  abort "FAILED: couldn't execute command (@session.channel.exec)"
                end
                channel.on_data do |stdout_channel, stdout_data|
                  stdout += stdout_data
                end

                channel.on_extended_data do |stderr_ch, type,stderr_data|
                  stderr += stderr_data
                end

                channel.on_request("exit-status") do |exitcode_ch, exitcode_data|
                  exit_code = exitcode_data.read_long
                end

                #channel.on_request("exit-signal") do |exitsignal_ch, exitsignal_data|
                #  exit_signal = exitsignal_data.read_long
                #end
              end
            end
            @session.loop

            logger.info("stdout: #{stdout}")
            logger.info("stderr: #{stderr}")
            logger.info("exit_code: #{exit_code}")
          end

          def with_tunnel(from_host, from_port, to_host, to_port)
            from, to = "#{from_host}:#{from_port}", "#{to_host}:#{to_port}"

            @logger.info("Creating tunnel from #{from} to #{to}")

            @session.forward.remote_to( 8140, to_host, 8140)

            @logger.info("Tunnel from #{from} to #{to} created.")

            @session.loop { yield }
          end
        end
      end
    end
  end
end