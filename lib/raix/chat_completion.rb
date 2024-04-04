# frozen_string_literal: true

# The `ChatCompletion`` module is a Rails concern that provides a way to interact
# with the OpenRouter Chat Completion API via its client. The module includes a few
# methods that allow you to build a transcript of messages and then send them to
# the API for completion. The API will return a response that you can use however
# you see fit. If the response includes a function call, the module will dispatch
# the function call and return the result. Which implies that function calls need
# to be defined on the class that includes this module. (Note: You should probably
# use the `FunctionDispatch` module to define functions instead of doing it manually.)
#
#
module Raix::ChatCompletion
  extend ActiveSupport::Concern

  protected

  # This method returns the transcript array.
  # Manually add your messages to it in the following abbreviated format
  # before calling `chat_completion`.
  #
  # { system: "You are a pumpkin" },
  # { user: "Hey what time is it?" },
  # { assistant: "Sorry, pumpkins do not wear watches" }
  #
  # to add a function result use the following format:
  # { function: result, name: 'fancy_pants_function' }
  #
  # @return [Array] The transcript array.
  def transcript
    @transcript ||= []
  end

  # This method performs chat completion based on the provided transcript and parameters.
  #
  # @param params [Hash] The parameters for chat completion.
  # @option params [Boolean] :raw (false) Whether to return the raw response or dig the text content.
  # @return [String|Hash] The completed chat response.
  def chat_completion(params: {}, raw: false)
    raise "Can't complete an empty transcript" if @transcript.blank?

    cc_messages = @transcript.map { |msg| transform_message_format(msg) }

    if self.class.respond_to?(:functions)
      params[:tools] = self.class.functions unless self.class.functions.blank?
    end

    puts "_" * 80
    puts "ChatCompletion#chat_completion: #{params} #{cc_messages}"
    puts "_" * 80

    # set params to default values if not provided
    params[:temperature] ||= temperature
    params[:max_tokens] ||= max_tokens

    OpenRouter::Client.new.chat_completion(cc_messages, model:, extras: params).then do |response|
      # todo: should be able to set this code in configuration block
      # todo: need to come up with a good name for account in this context (i.e. billable entity)
      # broadcast(:usage_event, account, self.class.name.to_s, response)

      # the assistant is asking for a function to be called, it needs to be defined on this class
      if (function = response.dig("choices", 0, "message", "tool_calls", 0, "function"))
        @current_function = function["name"]
        # dispatch the function call
        # todo: our own JSON.parse wrapper that is more robust using AI healing
        return send(function["name"], JSON.parse(function["arguments"]).with_indifferent_access)
      end

      # normal text response
      response.tap do |res|
        # todo: change to DEBUG level logger
        puts response
        puts "_" * 80

        # dig out the content unless the user has requested the raw response
        return res.dig("choices", 0, "message", "content") unless raw
      end
    end
  end

  # This method continues the chat with the provided result.
  #
  # @param result [Object] The result of the previous chat completion.
  def continue_with(result)
    @transcript << { function: result, name: @current_function }
    chat_completion
  end

  private

  def model
    "openai/gpt-4"
  end

  def temperature
    0.0
  end

  def max_tokens
    100
  end

  def transform_message_format(message)
    if message[:function].present?
      { role: "function", name: message[:name], content: message[:function] }
    else
      { role: message.first.first, content: message.first.last }
    end
  end
end
