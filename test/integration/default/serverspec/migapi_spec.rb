require 'serverspec'

# Required by serverspec
set :backend, :exec

describe process("mig-api") do

  its(:user) { should eq "vagrant" }

  it "is listening on port 51664" do
    expect(port(51664)).to be_listening
  end

end

