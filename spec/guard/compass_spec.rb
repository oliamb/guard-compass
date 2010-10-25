require 'fileutils'
require 'spec_helper'
require 'guard/compass'

describe Guard::Compass do
  subject { Guard::Compass.new }
  
  before :each do
    @project_path = File.expand_path('./compass_prj')
  end
  
  describe "start" do
    it "supports creation of the updater instance" do
      subject.updater.should be_nil
      subject.start
      subject.updater.should_not be_nil
    end
    
    it "should not generate anything" do
      File.exists?(@project_path + "/stylesheets/screen.css").should be_false
    end
  end
  
  describe "default options" do
    it "should have a default path mathching the run location" do
      subject.options[:path].should == File.expand_path(".")
      subject.start
    end
  end
  
  describe "after start" do
    
    before :each do
      FileUtils.mkdir(TMP_PATH) if ! File.exists? TMP_PATH
      @project_path = TMP_PATH + '/compass_prj'
      FileUtils.cp_r FIXTURES_PATH + '/compass_prj', TMP_PATH
      subject.options.merge!(:path => @project_path)
      
      subject.start
    end
    after :each do
      FileUtils.rm_rf(TMP_PATH)
      
      subject.stop
    end
    
    describe "stop" do
      it "Stop remove the updater" do
        subject.updater.should_not be_nil
        subject.stop
        subject.updater.should be_nil
      end
    end
    
    describe "run_on_change" do
      it "rebuilds all scss files in compass path" do
        File.exists?(@project_path + "/src/screen.scss").should(be_true)
        File.exists?(@project_path + "/stylesheets/screen.css").should be_false
        subject.run_on_change(@project_path + "/src/screen.scss")
        File.exists?(@project_path + "/stylesheets/screen.css").should be_true
      end
    end
    
    describe "run all" do
      it "rebuilds all scss files in compass path" do
        File.exists?(@project_path + "/src/screen.scss").should(be_true)
        File.exists?(@project_path + "/stylesheets/screen.css").should be_false
        subject.run_all
        File.exists?(@project_path + "/stylesheets/screen.css").should be_true
      end
    end
    
  end
end
