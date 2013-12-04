require 'log4r'
require 'rake/tasklib'
require 'rake/admin/error'
require 'rake/admin/validations'

module Rake
  module Admin
    module Buildout
      class Local < Rake::TaskLib
        attr_accessor :buildout_base_path, :bootstrap_cmd, :buildout_cmd,
                      :buildout_cfg_file, :buildout_cfg_content

        include Rake::Admin::Validations

        def initialize
          yield self if block_given?

          @logger = Log4r::Logger.new('rake:admin:buildout')
          @logger.outputters = Log4r::Outputter.stdout

          validate_not_nil(@buildout_cfg_file, "must define buildout.cfg file")
          validate_not_nil(@buildout_base_path, "must define base buildout path")
          validate_not_nil(@bootstrap_cmd, "must define bootstrap command")

          @buildout_cmd ||= "bin/buildout -c #{@buildout_cfg_file}"

          @buildout_cfg_path = File.join(@buildout_base_path, @buildout_cfg_file)
          @buildout_bin_path = File.join(@buildout_base_path, "bin")
          @buildout_script_path = File.join(@buildout_bin_path, "buildout")

          define
        end

        def define
          task :buildout_base_path do
            check_buildout_base_path
          end

          task :buildout_cfg => [:buildout_base_path] do
            buildout_cfg
          end

          desc "Bootstrap  with base path #{@buildout_base_path} command: #{@bootstrap_cmd}"
          task :bootstrap => [:buildout_cfg] do
            bootstrap
          end

          desc "Run buildout with base path #{@buildout_base_path}, configuration " +
               "file #{@buildout_cfg_file} and command #{@buildout_cmd}"
          task :run => [:buildout_cfg, :bootstrap] do
            run
          end
        end
        private
        def buildout_cfg
          if File.exists?(@buildout_cfg_path)
            @logger.info("#{@buildout_cfg_path} exists.")

            # If buildout.cfg path exists and content given the file is replaced.
            if @buildout_cfg_content.nil?
              @logger.info("Using #{@buildout_cfg_path} configuration.")
            else
              File.open(@buildout_cfg_path, 'w') { |f| f.write(@buildout_cfg_content) }
              @logger.info("#{@buildout_cfg_path} replaced with the given content.")
            end
          else
            if @buildout_cfg_content.nil?
              # If buildout.cfg path doesn't exists and no content given
              # we have not buildout.cfg to define.
              raise Rake::Admin::TaskConfigurationError.new(
                        "#{@buildout_cfg_path} doesn't exists and buildout_cfg_content isn't setted."
                    )
            else
              # If buildout.cfg path doesn't exists and content given
              # we create buildout.cfg file with this content.
              File.open(@buildout_cfg_path, 'w') { |f| f.write(@buildout_cfg_content) }
              @logger.info("#{@buildout_cfg_path} created with the given content.")
            end
          end
        end

        def bootstrap
          if File.exists?(@buildout_script_path)
            @logger.info("Buildout script exists skipping bootstrap.")
          else
            buildout_path_sh @bootstrap_cmd
          end
        end

        def run
          buildout_path_sh "#{@buildout_cmd}"
        end

        def check_buildout_base_path
          raise Rake::Admin::EnvironmentError.new(
            "Base buildout path #{@buildout_base_path} doesn't exist"
          ) unless File.exists?(@buildout_base_path)

          raise Rake::Admin::EnvironmentError.new(
                    "Base buildout path is not a directory"
          ) unless File.directory?(@buildout_base_path)
        end

        def buildout_path_sh(cmd)
          sh "cd #{@buildout_base_path} && #{cmd}"
        end
      end
    end
  end
end