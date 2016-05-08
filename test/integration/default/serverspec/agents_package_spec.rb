require 'serverspec'

# Required by serverspec
set :backend, :exec

describe command('ls -al /home/_mig/go/src/mig.ninja/mig/mig-agent*.deb') do
  its(:stdout) { should match /deb/ }
end

describe command('ls -al /home/_mig/go/src/mig.ninja/mig/mig-agent*.rpm') do
  its(:stdout) { should match /rpm/ }
end

