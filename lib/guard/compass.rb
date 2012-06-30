require 'guard'
require 'guard/guard'
require 'guard/watcher'
require 'guard/reporter'
require 'guard/compass_helper'

require 'compass'
require 'compass/commands'
require 'compass/logger'

module Guard
  class Compass < Guard
    attr_reader :updater, :working_path
    attr_accessor :reporter

    def initialize(watchers = [], options = {})
      super
      @reporter = Reporter.new
      @working_path = Pathname.pwd # the Guard base path is the current working_path
    end

    # Load Compass Configuration
    def create_watchers
      # root_path is the path to the compass project
      # working_path is the current Guard (and by extension Compass) working directory

      watchers.clear
      
      config_file = (options[:configuration_file] || ::Compass.detect_configuration_file(root_path))
      config_path = pathname(working_path, config_file)
      src_path = pathname(root_path, ::Compass.configuration.sass_dir)

      watchers.push Watcher.new(%r{^#{src_path.relative_path_from(working_path)}/.*})
      watchers.push Watcher.new(%r{^#{config_path.relative_path_from(working_path)}$})
    end

    def root_path
      options[:project_path].nil? ? working_path : pathname(working_path, options[:project_path])
    end

    def valid_sass_path?
      if(::Compass.configuration.sass_dir.nil?)
        reporter.failure("Sass files src directory not set.\nPlease check your Compass configuration.")
        return false
      end
      path = pathname(root_path, ::Compass.configuration.sass_dir )
      unless path.exist?
        reporter.failure("Sass files src directory not found: #{path}\nPlease check your Compass configuration.")
        return false
      else
        return true
      end
    end
    
    def valid_configuration_path?
      config_file = (options[:configuration_file] || ::Compass.detect_configuration_file(root_path))

      if(config_file.nil?)
        reporter.failure "Cannot find a Compass configuration file, please add information to your Guardfile guard 'compass' declaration."
        return false
      end
      
      config_path = pathname(working_path, config_file)

      unless(config_path.exist?)
        reporter.failure "Compass configuration file not found: #{config_path}\nPlease check Guard configuration."
        return false
      end
      
      return true
    end

    # Guard Interface Implementation

    # Compile all the sass|scss stylesheets
    def start
      create_updater
      reporter.announce "Guard::Compass is waiting to compile your stylesheets."
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
    def run_on_changes(paths)
      perform
    end

    private
      include CompassHelper

      # Cleanup of the given options
      def cleanup_options
        # Ensure configuration file make reference to an absolute path.
        if(options[:configuration_file])
          options[:configuration_file] = pathname(working_path, options[:configuration_file]).to_s
        end
      end

      def perform
        if valid_sass_path?
          begin
            @updater.execute
          rescue Sass::SyntaxError => e
            msg = "#{e.sass_backtrace_str}"
            ::Guard::Notifier.notify msg, :title => "Guard Compass", :image => :failed
            return false
          rescue Exception => e
            ::Guard::Notifier.notify e.to_s, :title => "Guard Compass", :image => :failed
            return false
          end
          true
        else
          false
        end
      end

      def create_updater
        cleanup_options
        if valid_configuration_path?
          @updater = ::Compass::Commands::UpdateProject.new(working_path.to_s, options)
          create_watchers
          return valid_sass_path?
        else
          return false
        end
      end
  end
end
