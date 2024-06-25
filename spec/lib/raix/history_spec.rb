RSpec.describe Raix::History do
  let(:dummy_model) { DummyModel.create! }

  before do
    allow(Raix.configuration).to receive(:history_max_tokens).and_return(8000)
  end

  describe '.history_max_tokens' do
    it 'sets and gets the history_max_tokens for the class' do
      DummyModel.history_max_tokens(15000)
      expect(DummyModel.get_history_max_tokens).to eq(15000)
    end

    it 'uses the default value when not set' do
      DummyModel.instance_variable_set(:@history_max_tokens, nil)
      expect(DummyModel.get_history_max_tokens).to eq(8000)
    end
  end

  describe '#transcript' do
    before do
      dummy_model.chat_messages.create!(role: 'user', content: 'Hello', tokens: 1)
      dummy_model.chat_messages.create!(role: 'assistant', content: 'Hi there', tokens: 2)
      dummy_model.chat_messages.create!(role: 'user', content: 'How are you?', tokens: 4)
    end

    it 'returns messages within the token limit' do
      DummyModel.history_max_tokens(6)
      expect(dummy_model.transcript).to eq([
        { role: 'assistant', content: 'Hi there' },
        { role: 'user', content: 'How are you?' }
      ])
    end

    it 'returns all messages if within token limit' do
      DummyModel.history_max_tokens(30)
      expect(dummy_model.transcript).to eq([
        { role: 'user', content: 'Hello' },
        { role: 'assistant', content: 'Hi there' },
        { role: 'user', content: 'How are you?' }
      ])
    end

    it 'returns an empty array if token limit is 0' do
      DummyModel.history_max_tokens(0)
      expect(dummy_model.transcript).to eq([])
    end
  end
end