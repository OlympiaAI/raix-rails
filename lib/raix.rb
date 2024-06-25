# frozen_string_literal: true

require_relative "raix/rails/version"
require_relative "raix/rails/engine"
require_relative "raix/chat_completion"
require_relative "raix/function_dispatch"
require_relative "raix/prompt_declarations"
require_relative "raix/history"

# The Raix module provides configuration options for the Raix gem.
module Raix
  # The Configuration class holds the configuration options for the Raix gem.
  class Configuration
    # The temperature option determines the randomness of the generated text.
    # Higher values result in more random output.
    attr_accessor :temperature

    # The max_tokens option determines the maximum number of tokens to generate.
    attr_accessor :max_tokens

    # The model option determines the model to use for text generation. This option
    # is normally set in each class that includes the ChatCompletion module.
    attr_accessor :model

    # The openrouter_client option determines the default client to use for communicatio.
    attr_accessor :openrouter_client

    # The openai_client option determines the OpenAI client to use for communication.
    attr_accessor :openai_client

    # The history_max_tokens option determines the maximum number of tokens to include in the history.
    attr_accessor :history_max_tokens


    DEFAULT_MAX_TOKENS = 1000
    DEFAULT_MODEL = "meta-llama/llama-3-8b-instruct:free"
    DEFAULT_TEMPERATURE = 0.0
    DEFAULT_HISTORY_MAX_TOKENS = 8000


    # Initializes a new instance of the Configuration class with default values.
    def initialize
      self.temperature = DEFAULT_TEMPERATURE
      self.max_tokens = DEFAULT_MAX_TOKENS
      self.model = DEFAULT_MODEL
      self.history_max_tokens = DEFAULT_HISTORY_MAX_TOKENS
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
