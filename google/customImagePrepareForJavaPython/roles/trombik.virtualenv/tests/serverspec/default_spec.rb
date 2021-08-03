require "spec_helper"
require "serverspec"

package = case os[:family]
          when "freebsd"
            "devel/py-virtualenv"
          when "redhat"
            "python-virtualenv"
          when "openbsd"
            "py-virtualenv"
          else
            "virtualenv"
          end

describe package(package) do
  it { should be_installed }
end

describe command "virtualenv --version" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should be_empty }
  its(:stdout) { should match(/^(?:virtualenv\s+)?\d+\.\d+\.\d+/) }
end

case os[:family]
when "freebsd"
  describe command "pkg info" do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should be_empty }
    its(:stdout) { should_not match(/py2\d+-virtualenv/) }
  end
end
