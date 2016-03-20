require 'serverspec'

# Required by serverspec
set :backend, :exec

describe process("mig-api") do

  its(:user) { should eq "mig" }

  it "is listening on port 1664" do
    expect(port(1664)).to be_listening
  end

end

