require 'serverspec'

# Required by serverspec
set :backend, :exec

describe file('/home/_mig/.bashrc') do
  its(:content) { should match /GOPATH/ }
end
#describe file('/home/_mig/.migrc'), :if => os[:family] == 'ubuntu' && os[:release] == '14.04' do
#  its(:content) { should match /keyid/ }
#end
#describe file('/home/_mig/.migrc'), :if => os[:family] == 'ubuntu' && os[:release] == '16.04' do
#  its(:content) { should match /keyid/ }
#end
#describe file('/home/_mig/.migrc'), :if => os[:family] == 'ubuntu' && os[:release] == '18.04' do
#  its(:content) { should match /keyid/ }
#end

### For some reason, stalling when called by serverspec. fine in CLI. mig has some progress bar that might affect / no way to disable it currently.
### time less than 1sec
#describe command('/home/_mig/go/src/github.com/mozilla/mig/bin/linux/amd64/mig-agent-search -c ~/.migrc "name like \'%%\'"') do
#  let(:sudo_options) { '-u mig -H' }
#  its(:stdout) { should match /online;/ }
#end
### time ~5min
#describe command('/home/_mig/go/src/github.com/mozilla/mig/bin/linux/amd64/mig -i /home/_mig/go/src/github.com/mozilla/mig/actions/integration_tests.json | tee /tmp/integration_tests.out') do
#  let(:sudo_options) { '-u mig -H' }
#  its(:stdout) { should match /0 agent has found results/ }
#end
