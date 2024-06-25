require 'tiktoken_ruby'

module Raix
  class ChatMessage < ApplicationRecord
    belongs_to :messageable, polymorphic: true

    validates :role, presence: true
    validates :content, presence: true
    validates :tokens, presence: true

    enum role: { system: 'system', user: 'user', assistant: 'assistant' }

    before_validation :calculate_tokens, if: :content_changed?

    private

    def calculate_tokens
      enc = Tiktoken.encoding_for_model("gpt-3.5-turbo")
      self.tokens = enc.encode(content).length
    end
  end
end