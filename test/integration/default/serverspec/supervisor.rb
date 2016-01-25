require 'spec_helper'

describe service('supervisor') do  
  it { should be_enabled   }
  it { should be_running   }
end  

