require 'spec_helper'
require 'spec_rake_admin'
require 'rake/admin/buildout'
require 'rake/admin/error'

describe "Rake::Admin::Buildout::Local(bootstrap task)" do
  it "if buildout script doesnt exist must run bootstrap command" do
    task = Rake::Admin::Buildout::Local.new do |t|
      t.bootstrap_cmd = 'test'
      t.buildout_base_path = Rake::Admin::Spec.resources_path
      t.buildout_cfg_file = 'buildout.cfg'
    end

    task.should_receive(:buildout_path_sh).with("test")

    task.send(:bootstrap)
  end

  it "if buildout script exists must not run bootstrap command" do
    task = Rake::Admin::Buildout::Local.new do |t|
      t.bootstrap_cmd = 'test'
      t.buildout_base_path = Rake::Admin::Spec.resources_path
      t.buildout_cfg_file = 'buildout.cfg'
    end

    begin
      Dir.mkdir(task.instance_variable_get(:@buildout_bin_path))
      File.open(task.instance_variable_get(:@buildout_script_path), 'w') { |f| f.write("test") }

      task.should_not_receive(:buildout_path_sh)

      task.send(:bootstrap)
    ensure
      FileUtils.rm_r(task.instance_variable_get(:@buildout_bin_path))
    end
  end
end