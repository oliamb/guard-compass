require 'fileutils'
require 'spec_helper'
require 'guard/compass'

def create_fixture(name)
  FileUtils.mkdir(TMP_PATH) if ! File.exists? TMP_PATH
  @project_path = "#{TMP_PATH}/#{name}"
  FileUtils.cp_r "#{FIXTURES_PATH}/#{name}", TMP_PATH
  subject.options.merge!(:working_directory => @project_path)
end

def remove_fixtures
  FileUtils.rm_rf(TMP_PATH)
end

describe Guard::Compass do
  
  after :each do
    ::Compass.reset_configuration!
  end
  
  describe "In a standard project" do
    subject { Guard::Compass.new }

    it "has a reporter" do
      subject.reporter.should_not be_nil
    end

    it "might be initialized with options" do
      g = Guard::Compass.new([], :working_directory => 'test', :configuration_file => 'test_also')
      g.options[:working_directory].should == 'test'
      g.options[:configuration_file].should == 'test_also'
    end
    
    before :each do
      create_fixture(:compass_prj)
    end
  
    after :each do
      remove_fixtures
      ::Compass.reset_configuration!
    end
  
    describe "start" do
      it "supports creation of the updater instance" do
        subject.updater.should be_nil
        subject.start.should be_true
        subject.updater.should_not be_nil
      end
    
      it "should not generate anything" do
        File.exists?(@project_path + "/stylesheets/screen.css").should be_false
      end
    end
  
    describe "default options" do
      it "should have a default path mathching the run location" do
        subject.options[:working_directory].should == @project_path
        subject.start.should be_true
      end
    end
  
    describe "after start" do
      
      before :each do
        subject.start
      end
      
      after :each do
        subject.stop
        ::Compass.reset_configuration!
      end
      
      describe "the updater" do
        it "should contains an options hashmap with config file values" do
          ::Compass.configuration.sass_path.should_not be_nil
          ::Compass.configuration.sass_path.should == "#{@project_path}/src"
        end
      end
      
      describe "stop" do
        it "Stop remove the updater" do
          subject.updater.should_not be_nil
          subject.stop.should be_true
          subject.updater.should be_nil
        end
      end
    
      describe "run_on_change" do
        it "rebuilds all scss files in compass path" do
          File.exists?(@project_path + "/src/screen.scss").should(be_true)
          File.exists?(@project_path + "/stylesheets/screen.css").should be_false
          subject.run_on_change(@project_path + "/src/screen.scss").should be_true
          File.exists?(@project_path + "/stylesheets/screen.css").should be_true
        end
      end
    
      describe "run all" do
        it "rebuilds all scss files in compass path" do
          File.exists?(@project_path + "/src/screen.scss").should(be_true)
          File.exists?(@project_path + "/stylesheets/screen.css").should be_false
          subject.run_all.should be_true
          File.exists?(@project_path + "/stylesheets/screen.css").should be_true
        end
      end
    
    end
  end
  
  describe "with custom configuration and locations" do
    subject { Guard::Compass.new }
    
    before :each do
      ::Compass.reset_configuration!
      create_fixture(:custom_config_file)
      subject.reporter.should_not_receive(:failure)
    end
  
    after :each do
      remove_fixtures
      subject.stop
      ::Compass.reset_configuration!
    end
    
    it "configure Compass correctly with an absolute path" do
      subject.options[:configuration_file] = "#{@project_path}/another_config_location/config.rb"
      subject.start
      Compass.configuration.sass_path.should == "#{@project_path}/another_src_location"
      Compass.configuration.sass_path.should == "#{@project_path}/another_src_location"
    end
    
    it "configure Compass correctly with a path relative to the workdir" do
      subject.options[:configuration_file] = "another_config_location/config.rb"
      subject.options[:working_directory] = @project_path
      subject.start
    end
    
    it "rebuilds all scss files in compass path" do
      subject.options[:configuration_file] = "#{@project_path}/another_config_location/config.rb"
      subject.start
      File.exists?("#{@project_path}/another_src_location/screen.scss").should(be_true)
      File.exists?("#{@project_path}/another_stylesheets_location/screen.css").should be_false
      subject.run_on_change(@project_path + "/another_src_location/screen.scss").should be_true
      File.exists?(@project_path + "/another_stylesheets_location/screen.css").should be_true
    end
  end
  
  describe "without config file" do
    subject { Guard::Compass.new }
    
    before :each do
      ::Compass.reset_configuration!
      create_fixture(:no_config_file)
      subject.reporter.stub!(:failure)
    end
  
    after :each do
      remove_fixtures
      subject.stop
      ::Compass.reset_configuration!
    end
    
    it "fails to build sass" do
      subject.reporter.should_receive(:failure).with("Cannot find a Compass configuration file, please add information to your Guardfile guard 'compass' declaration.")
      subject.start
      File.exists?(@project_path + "/src/screen.scss").should(be_true)
      File.exists?(@project_path + "/stylesheets/screen.css").should be_false
      
      subject.run_on_change(@project_path + "/bad_src/screen.scss")
    end
  end
  
  describe "with a bad directory configuration" do
    subject { Guard::Compass.new }
    
    before :each do
      create_fixture(:bad_src_directory)
      subject.reporter.stub!(:failure).with("Sass files src directory not found: #{@project_path}/src\nPlease check your Compass configuration.")
      subject.start
    end
  
    after :each do
      remove_fixtures
      subject.stop
      ::Compass.reset_configuration!
    end
    
    it "fails to build sass" do
      File.exists?(@project_path + "/bad_src/screen.scss").should(be_true)
      File.exists?(@project_path + "/stylesheets/screen.css").should be_false
      
      subject.run_on_change(@project_path + "/bad_src/screen.scss")
    end
  end
  
  describe "with a bad configuration file parameter" do
    subject { Guard::Compass.new([], :configuration_file => 'invalid.rb') }
    
    before :each do
      create_fixture(:custom_config_file)
    end
    
    after :each do
      subject.stop
      remove_fixtures
      ::Compass.reset_configuration!
    end
    
    it "reports an error" do
      subject.options[:configuration_file].should == 'invalid.rb'
      subject.reporter.stub!(:failure)
      subject.reporter.should_receive(:failure).with("Compass configuration file not found: #{@project_path}/invalid.rb\nPlease check Guard configuration.")
      subject.start
    end
  
  end
  
  describe "Watchers creation" do
    
    after :each do
      remove_fixtures
      ::Compass.reset_configuration!
    end
    
    describe "in standard project" do
      subject { 
        Guard::Compass.new 
      }

      before :each do
        create_fixture :compass_prj
      end

      it "should have some watchers" do
        subject.options.should eql :working_directory => "#{TMP_PATH}/compass_prj"
        subject.start
        subject.watchers.size.should(eql(2), subject.watchers.inspect)
        subject.watchers.first.pattern.should == "^src/.*"
        subject.watchers.last.pattern.should == "^config.rb$"
      end
    end
    
    describe "in customized project" do
      subject { 
        Guard::Compass.new([], :working_directory => "#{TMP_PATH}/custom_config_file", :configuration_file => 'another_config_location/config.rb') 
      }

      before :each do
        create_fixture :custom_config_file
      end

      it "should have some watchers" do
        subject.start
        subject.watchers.size.should(eql(2), subject.watchers.inspect)
        subject.watchers.first.pattern.should == "^another_src_location/.*"
        subject.watchers.last.pattern.should == "^another_config_location/config.rb$"
      end
    end
  end
end

def create_fixture(name)
  FileUtils.mkdir(TMP_PATH) if ! File.exists? TMP_PATH
  @project_path = "#{TMP_PATH}/#{name}"
  FileUtils.cp_r "#{FIXTURES_PATH}/#{name}", TMP_PATH
  subject.options.merge!(:working_directory => @project_path)
  
  Dir.stub!(:pwd).and_return(@project_path)
  Pathname.stub!(:pwd).and_return(Pathname.new(@project_path))
end

def remove_fixtures
  FileUtils.rm_rf(TMP_PATH)
end
