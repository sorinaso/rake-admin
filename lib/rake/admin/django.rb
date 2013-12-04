module Rake
  module Admin
    module Django
      class Local < Rake::TaskLib
        attr_accessor :manage_py_path

        def initialize
          yield self if block_given?
          raise "must define manage command path" if @manage_py_path.nil?

          define
        end

        def define
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

        private
        def manage_py(cmd)
          sh "#{manage_py_path} #{cmd}"
        end
      end
    end
  end
end