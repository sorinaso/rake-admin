require 'spec_helper'
require 'spec_rake_admin'
require 'rake/admin/utils/ssh'
require 'rake/admin/error'
require 'net/ssh'

describe "Rake::Admin::Utils::SSH" do
  it "should fail without ssh session data" do
    class TestSSHFail
      include Rake::Admin::Utils::SSH
    end

    test = TestSSHFail.new
    expect { test.logger }.to raise_error
    expect { test.session }.to raise_error
  end

  it "should not fail with ssh session data" do
    class TestSSHNotFail
      include Rake::Admin::Utils::SSH
    end

    Net::SSH.stub(:start) { mock("SSH session") }

    test = TestSSHFail.new
    test.ssh_start("test", "test")
    test.logger
    test.session
  end
end