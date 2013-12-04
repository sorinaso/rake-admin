require 'spec_helper'
require 'rake/admin/buildout'

describe 'Rake::Admin::Buildout::Local(initialization)' do
  it 'without parameters should raise TaskConfigurationError' do
    expect do
      Rake::Admin::Buildout::Local.new
    end.to raise_error(Rake::Admin::TaskConfigurationError)
  end

  it 'without buildout base path should raise TaskConfigurationError' do
    expect do
      Rake::Admin::Buildout::Local.new do |t|
        t.bootstrap_cmd = 'test'
        t.buildout_cfg_file = 'test'
      end
    end.to raise_error(Rake::Admin::TaskConfigurationError)
  end

  it 'without buildout.cfg path should raise TaskConfigurationError' do
    expect do
      Rake::Admin::Buildout::Local.new do |t|
        t.bootstrap_cmd = 'test'
        t.buildout_base_path = 'test'
      end
    end.to raise_error(Rake::Admin::TaskConfigurationError)
  end

  it 'without bootstrap command should raise TaskConfigurationError' do
    expect do
      Rake::Admin::Buildout::Local.new do |t|
        t.buildout_cfg_file = 'test'
        t.buildout_base_path = 'test'
      end
    end.to raise_error(Rake::Admin::TaskConfigurationError)
  end

  it 'normal initialization should work fine' do
    def task_common_params_should_be(t)
      t.instance_variable_get("@buildout_cfg_path").should be_eql("test/test")
      t.instance_variable_get("@buildout_bin_path").should be_eql("test/bin")
      t.instance_variable_get("@buildout_script_path").should be_eql("test/bin/buildout")
    end

    t1 = Rake::Admin::Buildout::Local.new do |t|
      t.bootstrap_cmd = 'test'
      t.buildout_base_path = 'test'
      t.buildout_cfg_file = 'test'
    end

    task_common_params_should_be(t1)

    t1.instance_variable_get("@buildout_cmd").should be_eql("bin/buildout -c test")

    t2 = Rake::Admin::Buildout::Local.new do |t|
      t.buildout_cmd = "test"
      t.bootstrap_cmd = 'test'
      t.buildout_base_path = 'test'
      t.buildout_cfg_file = 'test'
    end

    task_common_params_should_be(t2)
    t2.instance_variable_get("@buildout_cmd").should be_eql("test")
  end
end
