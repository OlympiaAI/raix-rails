module Raix
  module History
    extend ActiveSupport::Concern

    included do
      has_many :chat_messages, as: :messageable, dependent: :destroy, class_name: 'Raix::ChatMessage'
    end

    class_methods do
      def history_max_tokens(tokens)
        @history_max_tokens = tokens
      end

      def get_history_max_tokens
        @history_max_tokens || Raix.configuration.history_max_tokens
      end
    end

    def transcript
      @transcript ||= load_transcript_from_history
    end

    private

    def load_transcript_from_history
      messages = chat_messages.order(created_at: :desc)
      total_tokens = 0
      transcript = []

      messages.each do |msg|
        if total_tokens + msg.tokens > self.class.get_history_max_tokens
          break
        end
        total_tokens += msg.tokens
        transcript.unshift({ role: msg.role, content: msg.content })
      end

      transcript
    end
  end
end