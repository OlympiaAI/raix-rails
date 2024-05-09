# frozen_string_literal: true

require_relative "raix/rails/version"
require_relative "raix/chat_completion"
require_relative "raix/function_dispatch"
require_relative "raix/prompt_declarations"

# The Raix module provides configuration options for the Raix gem.
module Raix
  # The Configuration class holds the configuration options for the Raix gem.
  class Configuration
    # The temperature option determines the randomness of the generated text.
    # Higher values result in more random output.
    attr_accessor :temperature

    # The max_tokens option determines the maximum number of tokens to generate.
    attr_accessor :max_tokens

    # The open_router_client option determines the client to use for communication.
    attr_accessor :open_router_client

    DEFAULT_MAX_TOKENS = 1000
    DEFAULT_TEMPERATURE = 0.0

    # Initializes a new instance of the Configuration class with default values.
    def initialize
      @temperature = DEFAULT_TEMPERATURE
      @max_tokens = DEFAULT_MAX_TOKENS
    end
  end

  class << self
    attr_writer :configuration
  end

  # Returns the current configuration instance.
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Configures the Raix gem using a block.
  def self.configure
    yield(configuration)
  end
end
