# frozen_string_literal: true

require 'ostruct'

module PromptDeclarations
  extend ActiveSupport::Concern

  # todo: This module requires `ChatCompletion`, how do we handle that?

  # This module provides a way to chain prompts and handle
  # user responses in a serialized manner (in the order they were defined),
  # with support for functions if the FunctionDispatch module is also included.
  module ClassMethods
    # Adds a prompt to the list of prompts.
    #
    # @param system [Proc] A lambda that generates the system message.
    # @param text [Proc] A lambda that generates the prompt text. (Required)
    # @param success [Proc] The block of code to execute when the prompt is answered.
    # @param parameters [Hash] Additional parameters for the completion API call
    def prompt(system: nil, text:, success: nil, params: {})
      name = Digest::SHA256.hexdigest(text.inspect)[0..7]
      prompts << begin
        open_struct = OpenStruct.new({ name:, system:, text:, success:, params: })
      end

      define_method(name) do |response|
        if Rails.env.local?
          puts "_" * 80
          puts "PromptDeclarations#response:"
          puts "#{text.source_location} (#{name})"
          puts response
          puts "_" * 80
        end

        return response if success.nil?

        instance_exec(response, &success)
      end
    end

    # the list of prompts declared at class level
    def prompts
      @prompts ||= []
    end

    # getter/setter for system prompt declared at class level
    def system_prompt(prompt=nil)
      prompt ? @system_prompt = prompt.squish : @system_prompt
    end
  end

  # Raises an error if there are not enough prompts defined.
  #
  # @param params [Hash] Parameters for the chat completion.
  def chat_completion(params: {}, raw: false)
    raise "No prompts defined" unless self.class.prompts.present?

    current_prompts = self.class.prompts.clone

    while (@current_prompt = current_prompts.shift)
      system_prompt = self.class.system_prompt.presence
      system_prompt ||= instance_exec(&@current_prompt.system) unless @current_prompt.system.blank?
      transcript << { system: system_prompt } if system_prompt
      transcript << { user: instance_exec(&@current_prompt.text) } # text is required

      params = @current_prompt.params.merge(params)

      super(params:, raw:).then do |response|
        transcript << { assistant: response }
        @last_response = send(@current_prompt.name, response)
      end
    end

    @last_response
  end

  # Returns the model parameter of the current prompt or the default model.
  #
  # @return [Object] The model parameter of the current prompt or the default model.
  def model
    @current_prompt.params[:model] || super
  end

  # Returns the temperature parameter of the current prompt or the default temperature.
  #
  # @return [Float] The temperature parameter of the current prompt or the default temperature.
  def temperature
    @current_prompt.params[:temperature] || super
  end

  # Returns the max_tokens parameter of the current prompt or the default max_tokens.
  #
  # @return [Integer] The max_tokens parameter of the current prompt or the default max_tokens.
  def max_tokens
    @current_prompt.params[:max_tokens] || super
  end
end
