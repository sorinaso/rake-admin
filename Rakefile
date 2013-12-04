require "bundler/gem_tasks"
require 'rspec/core/rake_task'

desc "Deploys gems to serve with puppet modules."
task :deploy_to_puppet => [:build] do
  puppet_modules_path = '/home/sorin/mis_proyectos/puppet/puppet-modules/puppet/modules/admin/files/gem'
  gems_path = "pkg/*"

  sh "cp #{gems_path} #{puppet_modules_path}"
end

RSpec::Core::RakeTask.new('spec')

