require 'spec_helper'
require 'spec_rake_admin'
require 'rake/admin/django/local/application'
require 'rake/admin/error'

describe "Rake::Admin::Django::Application::Local(bootstrap task)" do
  it "shoud generate config.ini" do
    config_ini_file = '/tmp/django_application_config.ini'

    task = Rake::Admin::Django::Application::Local.new do |t|
      t.manage_py_path = '/tmp/manage.py'
      t.config_ini_path = config_ini_file
      t.config_ini_sections = {
        :global => {
          :a => "a",
          :b => "b",
        }
      }
    end

    task.send(:config)

    File.read(config_ini_file).should eql("[global]\na = a\nb = b\n\n")
  end
end