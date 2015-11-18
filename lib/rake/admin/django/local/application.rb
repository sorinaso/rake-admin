require 'inifile'
require 'rake/tasklib'

module Rake
  module Admin
    module Django
      module Application
        class Local < Rake::TaskLib
          attr_accessor :manage_py_path, :config_ini_path, :config_ini_sections

          def initialize
            yield self if block_given?

            raise "must define manage_py_path" if @manage_py_path.nil?
            raise "must define config_ini_path" if @config_ini_path.nil?
            raise "must define config_ini_sections" if @config_ini_sections.nil?
            raise "must define deploy_stop_services" if @deploy_stop_services.nil?
            raise "must define git_path" if @git_path
            raise "must define git_repository" if @git_repository

            define
          end

          def define
            namespace :supervisor do
              Rake::Admin::Supervisor::Local.new
            end

            namespace :git do
              Rake::Admin::Git::Local.new do |t|
                t.git_path       = @git_path
                t.git_repository = @git_repository
              end
            end

            namespace :django do
              desc "Migrates the database."
              task :db_migrate do
                manage_py "syncdb --migrate --noinput"
              end

              desc "Update static"
              task :static_update => 'git:repository' do
                manage_py "collectstatic --noinput"
              end

              desc "Execute generic manage command"
              task :manage_py, :cmd do |t, args|
                manage_py args[:cmd]
              end
            end

            namespace :app do
              task :config do
                config
              end

              task :build do
                sh 'find panal -name "*.pyc" -delete'
                sh 'rake buildout:run'
              end

              task :branch, [:name] do |t,args|
                fail "Se debe pasar el nombre del branch a la tarea app:branch" unless args[:name]

                Rake::Task['git:fetch'].invoke
                Rake::Task['git:branch'].invoke(args[:name])
              end

              task :ci, [:branch] do |t,args|
                Rake::Task['branch'].invoke(args[:branch]) if args[:branch]
                Rake::Task['config'].invoke
                Rake::Task['build'].invoke
                Rake::Task['django:db_migrate'].invoke
                Rake::Task['django:manage_py'].invoke('jenkins --traceback')
              end

              namespace :deploy do
                task :full, [:branch] do |t, args|
                  refresh_services = "apache celeryd celerycam"

                  sh "rake supervisor:start"
                  sh "rake supervisor:stop['#{refresh_services}']"

                  Rake::Task['app:branch'].invoke(args[:branch]) if args[:branch]
                  Rake::Task['app:config'].invoke
                  Rake::Task['app:build'].invoke

                  sh 'rake django:db_migrate django:static_update'

                  sh 'sudo chmod -R o+r panal'
                  sh 'sudo chmod -R o+w panal'

                  sh 'rake django:manage_py[clean_sorl_cache]'
                  sh "rake supervisor:start['#{refresh_services}']"
                end
              end
            end
          end
          private
          def config
            ini = IniFile.new(:filename => @config_ini_path)

            @config_ini_sections.each { |section, content| ini[section] = content }

            ini.write
          end

          def manage_py(cmd)
            sh "#{@manage_py_path} #{cmd}"
          end
        end
      end
    end
  end
end