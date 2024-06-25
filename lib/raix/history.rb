module Raix
  module History
    extend ActiveSupport::Concern

    included do
      has_many :chat_messages, -> { order(id: :asc) }, 
               as: :messageable, 
               class_name: 'Raix::ChatMessage'
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
      max_tokens = self.class.get_history_max_tokens
    
      messages = chat_messages
        .select('role, content, tokens, created_at')
        .order(created_at: :asc)
    
      total_tokens = 0
      result = []
    
      messages.reverse.each do |msg|
        new_total = total_tokens + msg.tokens
        break if new_total > max_tokens
        result << { role: msg.role, content: msg.content }
        total_tokens = new_total
      end
    
      result.reverse
    end
  end
end