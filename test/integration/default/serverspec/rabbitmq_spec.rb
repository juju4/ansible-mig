#require 'spec_helper'
require 'serverspec'

# Required by serverspec
set :backend, :exec

describe package('rabbitmq-server'), :if => os[:family] == 'redhat' do
  it { should be_installed }
end

describe package('rabbitmq-server'), :if => os[:family] == 'ubuntu' do
  it { should be_installed }
end

describe service('rabbitmq-server'), :if => os[:family] == 'redhat' do
  it { should be_enabled }
  it { should be_running }
end

describe service('rabbitmq-server'), :if => os[:family] == 'ubuntu' do
  it { should be_enabled }
  it { should be_running }
end

#describe service('org.apache.httpd'), :if => os[:family] == 'darwin' do
#  it { should be_enabled }
#  it { should be_running }
#end

#describe port(5671) do
#  it { should be_listening }
#end
describe port(5672) do
  it { should be_listening }
end

