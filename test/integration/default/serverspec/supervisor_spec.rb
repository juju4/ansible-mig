require 'serverspec'

# Required by serverspec
set :backend, :exec

describe service('supervisor'), :if => os[:family] == 'ubuntu' do
  it { should be_enabled   }
  it { should be_running   }
end  

describe service('supervisord'), :if => os[:family] == 'redhat' do
#  it { should be_enabled }	## FIXME! for some reason...
  it { should be_running }
end

