require "rails_helper"

RSpec.describe LlmClient do
  describe "#initialize" do
    it "maps known OpenAI model to openai provider" do
      client = described_class.new(model: "gpt-4o-mini")
      expect(client.model).to eq("gpt-4o-mini")
      expect(client.provider).to eq(:openai)
    end

    it "maps known Anthropic model to anthropic provider" do
      client = described_class.new(model: "claude-haiku-4-5")
      expect(client.model).to eq("claude-haiku-4-5")
      expect(client.provider).to eq(:anthropic)
    end

    it "raises UnknownModelError for an unrecognized model" do
      expect { described_class.new(model: "llama-3-70b") }
        .to raise_error(LlmClient::UnknownModelError, /llama-3-70b/)
    end
  end

  describe "#ask", :vcr do
    it "executes an OpenAI call and returns content" do
      client = described_class.new(model: "gpt-4o-mini")
      response = client.ask("Odpowiedz jednym slowem: stolica Polski?")

      expect(response).to be_a(String).or be_a(Hash)
      expect(response.to_s.downcase).to include("warszaw")
    end

    it "executes an Anthropic call and returns content" do
      client = described_class.new(model: "claude-haiku-4-5")
      response = client.ask("Odpowiedz jednym slowem: stolica Polski?")

      expect(response.to_s.downcase).to include("warszaw")
    end
  end
end
