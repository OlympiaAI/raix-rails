# frozen_string_literal: true

class MeaningOfLife
  include Raix::ChatCompletion

  def initialize
    self.seed = 9999
    transcript << { user: "What is the meaning of life?" }
  end

  def model
    "meta-llama/llama-3-8b-instruct:free"
  end
end

RSpec.describe MeaningOfLife do
  subject { described_class.new }

  it "does a completion" do
    expect(subject.chat_completion).to include("The meaning of life is a question")
  end
end
