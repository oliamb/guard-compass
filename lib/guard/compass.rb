require 'guard'
require 'guard/guard'
require 'guard/reporter'

require 'compass'
require 'compass/commands'
require 'compass/logger'

module Guard
  class Compass < Guard
    attr_reader :updater, :options
    attr_accessor :reporter
    
    VERSION = '0.0.6'
    
    def initialize(watchers = [], options = {})
      super
      @reporter = Reporter.new
      @options[:workdir] ||= File.expand_path(File.dirname("."))
    end
    
    # Guard Interface Implementation
    
    # Compile all the sass|scss stylesheets
    def start
      create_updater
      UI.info "Guard::Compass is watching at your stylesheets."
      true
    end
    
    def stop
      @updater = nil
      true
    end
    
    # Reload the configuration
    def reload
      create_updater
      true
    end
    
    # Compile all the sass|scss stylesheets
    def run_all
      perform
    end
    
    # Compile the changed stylesheets
    def run_on_change(paths)
      perform
    end
    
    private
      def perform
        if valid_sass_path?
          @updater.execute
          true
        else
          false
        end
      end
      
      def create_updater
        if(options[:configuration_file])
          filepath = Pathname.new(options[:configuration_file])
          if(filepath.relative?)
            filepath = Pathname.new([options[:workdir], options[:configuration_file]].join("/"))
          end
          if(filepath.exist?)
            ::Compass.add_configuration filepath
            options[:configuration_file] = filepath
          else
            reporter.failure "Cannot find the Compass configuration file: " + filepath + "\nPlease check your configuration."
          end
        end
        @updater = ::Compass::Commands::UpdateProject.new(@options[:workdir] , @options)
        valid_sass_path?
      end
      
      def valid_sass_path?
        unless File.exists? ::Compass.configuration.sass_path
          reporter.failure("Sass files src directory not found: #{::Compass.configuration.sass_path}\nPlease check your Compass configuration.")
          false
        else
          true
        end
      end
  end
end