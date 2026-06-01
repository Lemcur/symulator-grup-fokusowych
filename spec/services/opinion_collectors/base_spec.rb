require "rails_helper"

RSpec.describe OpinionCollectors::Base do
  describe "#call" do
    it "raises NotImplementedError in the base class" do
      persona = create(:persona)
      expect { described_class.new.call(persona: persona) }.to raise_error(NotImplementedError)
    end
  end

  describe "#create_opinion (via subclass)" do
    let(:persona) { create(:persona) }
    let(:llm_data) do
      {
        "rating" => 4,
        "pros" => "konkretny plus dla tej osoby",
        "cons" => "konkretna obawa",
        "quote" => "to ma sens dla mnie"
      }
    end

    subject(:subclass) do
      Class.new(described_class) do
        def call(persona:, data:, llm_model:, llm_provider:)
          create_opinion(
            persona: persona,
            data: data,
            llm_model: llm_model,
            llm_provider: llm_provider
          )
        end
      end
    end

    it "creates Opinion with round=0, status=collected and required fields" do
      opinion = subclass.new.call(
        persona: persona,
        data: llm_data,
        llm_model: "gpt-4o-mini",
        llm_provider: "openai"
      )

      expect(opinion).to be_persisted
      expect(opinion.round).to eq(0)
      expect(opinion).to be_collected
      expect(opinion.rating).to eq(4)
      expect(opinion.pros).to eq("konkretny plus dla tej osoby")
      expect(opinion.cons).to eq("konkretna obawa")
      expect(opinion.quote).to eq("to ma sens dla mnie")
      expect(opinion.persona).to eq(persona)
      expect(opinion.focus_group).to eq(persona.focus_group)
      expect(opinion.raw_response).to include("llm_model" => "gpt-4o-mini", "llm_provider" => "openai")
    end

    it "raises KeyError when required fields are missing" do
      expect {
        subclass.new.call(
          persona: persona,
          data: { "rating" => 4 },
          llm_model: "gpt-4o-mini",
          llm_provider: "openai"
        )
      }.to raise_error(KeyError)
    end
  end
end
