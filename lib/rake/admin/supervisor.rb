require 'rake/tasklib'

module Rake
  module Admin
    module Supervisor
      class Local < Rake::TaskLib
        attr_accessor :git_path, :git_repository

        def initialize
          define
        end

        def define
          desc "Inicia los servicios."
          task :start, :service do |t, args|
            args.with_defaults(:service => 'all')

            sh "sudo supervisorctl start #{args[:service]}"

            # Para que Redis levante a memoria.
            sleep 5
          end

          desc "Detiene los servicios."
          task :stop, [:service] do |t, args|
            args.with_defaults(:service => 'all')

            sh "sudo supervisorctl stop #{args[:service]}"
          end

          desc "Reinicia los servicios."
          task :restart do
            Rake::Task['app:services:stop'].execute
            Rake::Task['app:services:start'].execute
          end
        end
      end
    end
  end
end
