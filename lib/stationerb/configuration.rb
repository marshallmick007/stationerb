module Stationerb
  class Configuration
    attr_accessor :font, :views

    attr_reader :built_in_views

    DEFAULT_FONT = "'Helvetica Neue',Helvetica,Arial,sans-serif"

    def initialize
      @font = DEFAULT_FONT
      @views = nil
      @built_in_views = compute_built_in_views_path
    end

    def compute_built_in_views_path
      File.expand_path File.join( File.expand_path(File.dirname(__FILE__)), "..", "views")
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
