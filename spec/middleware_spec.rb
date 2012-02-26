require 'gearup'

describe Gearup::Middleware do

  let(:middleware_class) { stub }
  let(:middleware) { stub }
  let(:ability) { stub }

  it 'wraps middleware around abilities' do
    geared_up = Gearup::Middleware.new(middleware_class)

    middleware_class.stub(:new).with(ability) { middleware }

    geared_up.wrapping(ability).should == middleware
  end

  it 'wraps middleware with dependencies around abilities' do
    dependency = stub
    geared_up = Gearup::Middleware.new(middleware_class, dependency)

    middleware_class.stub(:new).with(ability, dependency) { middleware }

    geared_up.wrapping(ability).should == middleware
  end

end
