require 'spec_helper'
require 'guard'
require 'guard/compass_helper'

describe Guard::CompassHelper do
  subject {self}
  
  include Guard::CompassHelper
  
  before :each do
    Pathname.stub!(:pwd).and_return(Pathname.new('/test/me'))
  end
  
  describe "pathname method" do
    it "retrieve pwd when nothing given" do
      subject.pathname.should == Pathname.new('/test/me')
    end
    
    it "retrieve the absolut path as it" do
      subject.pathname('/hello/boy').should == Pathname.new('/hello/boy')
    end
    
    it "computes the relative path" do
      subject.pathname('a', 'b', 'c').should == Pathname.new('/test/me/a/b/c')
    end
    
    it "takes the absolute path in middle of the run" do
      subject.pathname('a', '/another/test', 'c').should == Pathname.new('/another/test/c')
    end
    
    it "understand double dot notation" do
      subject.pathname('..').should == Pathname.new('/test')
      subject.pathname('..').to_s.should == '/test'
      subject.pathname('..', 'a/d/c').should == Pathname.new('/test/a/d/c')
      

      subject.pathname('..', 'custom_config_file/another_config_location/config.rb').to_s.should == '/test/custom_config_file/another_config_location/config.rb'
    end
  end
  
end