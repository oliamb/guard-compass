require 'spec_helper'
require 'guard'
require 'guard/dsl'

describe Guard::Dsl do
  subject {Guard::Dsl}
  
  it "load a guard from the DSL" do
    File.exists?("#{FIXTURES_PATH}/dsl/simple").should be_true
    File.exists?("#{FIXTURES_PATH}/dsl/simple/Guardfile").should be_true
    
    ## Hack to make guard look into the correct fixture folder
    Dir.stub!(:pwd).and_return("#{FIXTURES_PATH}/dsl/simple")
    Dir.pwd.should == "#{FIXTURES_PATH}/dsl/simple"
    
    ::Guard.stub!(:add_guard)
    ::Guard.should_receive(:add_guard).with('compass', [], [], hash_including(:project_path, :configuration_file))
    subject.evaluate_guardfile
  end
end