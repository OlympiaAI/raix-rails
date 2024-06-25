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
      
      return [] if max_tokens == 0

      chat_messages
        .select('role, content')
        .where("id >= (SELECT COALESCE(MIN(id), 0) FROM (SELECT id, SUM(tokens) OVER (ORDER BY created_at DESC) AS cumulative_tokens FROM raix_chat_messages WHERE messageable_type = ? AND messageable_id = ?) AS subquery WHERE cumulative_tokens <= ?)", self.class.name, self.id, max_tokens)
        .order(created_at: :asc)
        .map { |msg| { role: msg.role, content: msg.content } }
    end
  end
end