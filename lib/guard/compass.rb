require 'guard'
require 'guard/guard'

require 'compass'
require 'compass/commands'
require 'compass/logger'

module Guard
  class Compass < Guard
    attr_reader :updater
    
    VERSION = '0.0.5'
    
    def initialize(watchers = [], options = {})
      @watchers, @options = watchers, options
      super
      @options.merge!(:path => File.expand_path(File.dirname(".")) )
    end
    
    # Guard Interface Implementation
    
    # Compile all the sass|scss stylesheets
    def start
      create_updater
      UI.info "Guard::Compass is watching at your stylesheets."
    end
    
    def stop
      @updater = nil
    end
    
    # Reload the configuration
    def reload
      create_updater
    end
    
    # Compile all the sass|scss stylesheets
    def run_all
      @updater.execute
    end
    
    # Compile the changed stylesheets
    def run_on_change(paths)
      @updater.execute
    end
    
    private
      def create_updater
        @updater = ::Compass::Commands::UpdateProject.new(@options[:path], @options)
      end
  end
end