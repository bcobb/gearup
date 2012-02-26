require 'gearup'

describe Gearup::Worker do

  it 'enables abilities' do
    ability = stub
    subject.enable ability

    subject.ability.should == ability
  end

end
