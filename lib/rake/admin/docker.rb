require 'rake/tasklib'
require 'rake/admin/validations'

module Rake
  module Admin
    module DockerImage
      class Local < Rake::TaskLib
        attr_accessor :tag, :path, :repository

        include Rake::Admin::Validations

        def initialize
          yield self if block_given?

          validate_not_nil(@repository, "must define repository parameter")
          validate_not_nil(@tag, "must define tag parameter")
          validate_not_nil(@path,"must define path parameter")

          @repository_and_tag = "#{@repository}:#{@tag}"

          define
        end

        def define

          desc "Build the docker image with the tag `#{@repository_and_tag}` from Dockerfile in path `#{@path}`"
          task :build do
            sh "docker build -t #{@repository_and_tag} #{@path}"
          end

          desc "Run a container with a terminal from the docker image `#{@repository_and_tag}`"
          task :run_container do
            sh "docker run -it #{@repository_and_tag}"
          end
        end
      end
    end
  end
end
