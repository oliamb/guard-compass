require 'guard'
require 'guard/guard'

require 'compass'
require 'compass/commands'
require 'compass/logger'

module Guard
  class Compass < Guard
    attr_reader :updater
    
    VERSION = '0.0.6'
    
    def initialize(watchers = [], options = {})
      super
      @options[:workdir] = File.expand_path(File.dirname("."))
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
      @updater.execute
      true
    end
    
    # Compile the changed stylesheets
    def run_on_change(paths)
      @updater.execute
      true
    end
    
    private
      def create_updater
        @updater = ::Compass::Commands::UpdateProject.new(@options[:workdir] , @options)
      end
  end
end