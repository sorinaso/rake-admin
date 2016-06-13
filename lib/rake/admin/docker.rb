require 'rake/tasklib'
require 'rake/admin/validations'

module Rake
  module Admin
    module Docker
      class Image < Rake::TaskLib
        attr_accessor :name, :dockerfile_path

        include Rake::Admin::Validations

        def initialize
          yield self if block_given?

          validate_not_nil(@name, "must define the name parameter")
          validate_not_nil(@dockerfile_path,"must define dockerfile_path parameter")

          define
        end

        def define

          desc "Build the docker image with the tag `#{@name}` from Dockerfile in path `#{@dockerfile_path}`"
          task :build do
            sh "docker build -t #{@name} #{@dockerfile_path}"
          end
        end
      end

      class Container < Rake::TaskLib

        attr_accessor :name, :image_name, :run_parameters, :run_command

        include Rake::Admin::Validations

        def initialize
          yield self if block_given?

          validate_not_nil(@name, "must define the name parameter")
          validate_not_nil(@image_name,"must define image_name parameter")

          @run_parameters ||= ''

          @run_command ||= ''

          define
        end

        def define

          desc "Inicia el container #{@name}"
          task :start do
            sh "docker start '#{@name}'"
          end

          desc "Se atachea al container #{@name}"
          task :attach do
            sh "docker attach '#{@name}'"
          end

          desc "Borra el container #{@name}"
          task :delete do
            sh "docker rm -f '#{@name}'"
          end

          desc "Abre un shell en un container de docker."
          task :run do
            sh "docker run #{@run_parameters} --name '#{@name}' #{@image_name} #{@run_command}"
          end
        end

      end
    end
  end
end
