require "rails_helper"

RSpec.describe DeliberationServices::Base do
  describe "#call" do
    it "raises NotImplementedError in the base class" do
      persona = create(:persona)
      expect {
        described_class.new.call(persona: persona, peer_opinions: [])
      }.to raise_error(NotImplementedError)
    end
  end

  describe "#create_revised_opinion (via subclass)" do
    let(:persona) { create(:persona) }
    let(:llm_data) do
      {
        "rating" => 3,
        "pros" => "doceniona elastyczność po dyskusji",
        "cons" => "nadal koszt subskrypcji",
        "quote" => "po dyskusji widzę więcej zalet ale obawy zostają",
        "revised" => true,
        "revision_rationale" => "argument Marka o tygodniowych celach mnie przekonał"
      }
    end

    subject(:subclass) do
      Class.new(described_class) do
        def call(persona:, data:, llm_model:, llm_provider:)
          create_revised_opinion(
            persona: persona,
            data: data,
            llm_model: llm_model,
            llm_provider: llm_provider
          )
        end
      end
    end

    it "creates Opinion with round=1, revised flag and rationale" do
      opinion = subclass.new.call(
        persona: persona,
        data: llm_data,
        llm_model: "gpt-4o-mini",
        llm_provider: "openai"
      )

      expect(opinion).to be_persisted
      expect(opinion.round).to eq(1)
      expect(opinion).to be_collected
      expect(opinion.rating).to eq(3)
      expect(opinion.revised).to be true
      expect(opinion.revision_rationale).to eq("argument Marka o tygodniowych celach mnie przekonał")
      expect(opinion.raw_response).to include("llm_model" => "gpt-4o-mini")
    end

    it "raises KeyError when required fields are missing" do
      expect {
        subclass.new.call(
          persona: persona,
          data: { "rating" => 3 },
          llm_model: "gpt-4o-mini",
          llm_provider: "openai"
        )
      }.to raise_error(KeyError)
    end
  end
end
