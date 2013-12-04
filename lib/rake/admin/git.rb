require 'rake/admin/error'

module Rake
  module Admin
    module Git
      class Local < Rake::TaskLib
        attr_accessor :git_path, :git_repository

        def initialize
          yield self if block_given?
          raise "must define manage git path" if @git_path.nil?
          raise "must define manage git repository" if @git_repository.nil?

          define
        end

        def define
          desc "Clone repository #{@git_repository} if must."
          task :repository do
            if File.exists?(@git_path)
              raise Rake::Admin::TaskConfigurationError.new(
                "#{@git_path} is not a invalid git repository"
              ) unless valid_git_repository?(@git_path)
            else
              sh "git clone #{@git_repository}"
            end
          end

          desc "Checkout a branch"
          task :branch, [:name] => [:repository] do |t, args|
            git "checkout #{args[:name]}"
          end

          desc "Fetch repository for new changes"
          task :fetch => :repository do
            git "fetch"
          end

          desc "2 refs diff"
          task :diff, [:ref1, :ref2] do |t, args|
            git "diff #{args[:ref1]} #{args[:ref2]} --stat"
          end
        end

        private
        def git(cmd)
          sh "cd #{@git_path} && git #{cmd}"
        end

        def valid_git_repository?(path)
          File.directory?(File.join(@git_path, ".git"))
        end
      end
    end
  end
end