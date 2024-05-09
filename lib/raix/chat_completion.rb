# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/object/blank"
require "open_router"

module Raix
  # The `ChatCompletion`` module is a Rails concern that provides a way to interact
  # with the OpenRouter Chat Completion API via its client. The module includes a few
  # methods that allow you to build a transcript of messages and then send them to
  # the API for completion. The API will return a response that you can use however
  # you see fit. If the response includes a function call, the module will dispatch
  # the function call and return the result. Which implies that function calls need
  # to be defined on the class that includes this module. (Note: You should probably
  # use the `FunctionDispatch` module to define functions instead of doing it manually.)
  module ChatCompletion
    extend ActiveSupport::Concern

    attr_accessor :frequency_penalty, :logit_bias, :logprobs, :min_p, :presence_penalty, :repetition_penalty,
                  :response_format, :stream, :temperature, :max_tokens, :seed, :stop, :top_a, :top_k, :top_logprobs,
                  :top_p, :tools, :tool_choice, :provider

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
    def chat_completion(params: {}, json: false, raw: false, openai: false)
      cc_messages = transcript.flatten.compact.map { |msg| transform_message_format(msg) }
      raise "Can't complete an empty transcript" if cc_messages.blank?

      # set params to default values if not provided
      params[:temperature] ||= temperature.presence || 0.0
      params[:max_tokens] ||= max_tokens.presence || 500
      params[:stop] ||= stop.presence
      params[:frequency_penalty] ||= frequency_penalty.presence
      params[:logit_bias] ||= logit_bias.presence
      params[:logprobs] ||= logprobs.presence
      params[:min_p] ||= min_p.presence
      params[:presence_penalty] ||= presence_penalty.presence
      params[:repetition_penalty] ||= repetition_penalty.presence
      params[:provider] ||= provider.presence
      params[:response_format] ||= response_format.presence
      params[:seed] ||= seed.presence
      params[:top_a] ||= top_a.presence
      params[:top_k] ||= top_k.presence
      params[:top_logprobs] ||= top_logprobs.presence
      params[:top_p] ||= top_p.presence
      params[:tools] ||= tools.presence
      params[:tool_choice] ||= tool_choice.presence

      if json
        params[:provider] ||= {}
        params[:provider][:require_parameters] = true
        params[:response_format] ||= {}
        params[:response_format][:type] = "json_object"
      end

      if openai
        params[:stream] ||= stream.presence

        OPEN_AI_CLIENT.chat(parameters: params.compact.merge(model: openai, messages: cc_messages)).then do |response|
          return if stream && response.blank?

          if (function = response.dig("choices", 0, "message", "tool_calls", 0, "function"))
            @current_function = function["name"]
            return send(function["name"], JSON.parse(function["arguments"]).with_indifferent_access)
          end

          response.tap do |res|
            content = res.dig("choices", 0, "message", "content")
            if json
              raise "Cannot parse blank JSON return: #{res.to_json}" if content.blank?

              return JSON.parse(content)
            end

            return content unless raw
          end
        end
      else
        OpenRouter::Client.new.complete(cc_messages, model:, extras: params.compact, stream:).then do |response|
          return if stream && response.blank?

          if (function = response.dig("choices", 0, "message", "tool_calls", 0, "function"))
            @current_function = function["name"]
            return send(function["name"], JSON.parse(function["arguments"]).with_indifferent_access)
          end

          response.tap do |res|
            content = res.dig("choices", 0, "message", "content")
            if json
              raise "Cannot parse blank JSON return: #{res.to_json}" if content.blank?

              return JSON.parse(content)
            end

            return content unless raw
          end
        end
      end
    end

    # This method continues the chat with the provided result.
    #
    # @param result [Object] The result of the previous chat completion.
    def continue_with(result)
      @transcript << { name: @current_function, result: }
      chat_completion
    end

    private

    def model
      "openai/gpt-4-turbo"
    end

    def transform_message_format(message)
      if message[:function].present?
        { role: "assistant", name: message.dig(:function, :name),
          content: message.dig(:function, :arguments).to_json }
      elsif message[:result].present?
        { role: "function", name: message[:name], content: message[:result] }
      else
        { role: message.first.first, content: message.first.last }
      end
    end
  end
end
