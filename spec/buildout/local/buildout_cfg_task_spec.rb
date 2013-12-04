require 'spec_helper'
require 'spec_rake_admin'
require 'rake/admin/buildout'
require 'rake/admin/error'

describe "Rake::Admin::Buildout::Local(buildout_cfg task)" do
  before(:all) do
    @existent_buildout_cfg =File.join(Rake::Admin::Spec.resources_path, 'buildout.cfg')

    File.open(@existent_buildout_cfg, 'w') { |f| f.write("test") }
  end

  # buildout_cfg task
  it "if buildout.cfg path doesn't exist and content no given should raise TaskConfigurationError" do
    expect do
      Rake::Admin::Buildout::Local.new do |t|
        t.bootstrap_cmd = 'test'
        t.buildout_base_path = '/tmp'
        t.buildout_cfg_file = 'buildout.cfg'
      end.send(:buildout_cfg)
    end.to raise_error(Rake::Admin::TaskConfigurationError)
  end

  it "if buildout.cfg path exists and content no given should work fine and unchanged content" do
    Rake::Admin::Buildout::Local.new do |t|
      t.bootstrap_cmd = 'test'
      t.buildout_base_path = Rake::Admin::Spec.resources_path
      t.buildout_cfg_file = 'buildout.cfg'
    end.send(:buildout_cfg)

    File.read(@existent_buildout_cfg).should eql("test")
  end

  it "if buildout.cfg path exists and content given should work fine and changed content" do
    Rake::Admin::Buildout::Local.new do |t|
      t.bootstrap_cmd = 'test'
      t.buildout_base_path   = Rake::Admin::Spec.resources_path
      t.buildout_cfg_file    = 'buildout.cfg'
      t.buildout_cfg_content = 'changed_test'
    end.send(:buildout_cfg)
  end
end