require "rails_helper"

RSpec.describe ChairmanServices::Base do
  describe "#call" do
    it "raises NotImplementedError in the base class" do
      focus_group = create(:focus_group)
      expect { described_class.new.call(focus_group: focus_group) }.to raise_error(NotImplementedError)
    end
  end

  describe "#create_recommendation (via subclass)" do
    let(:focus_group) { create(:focus_group, sample_size: 3) }
    let(:personas) { create_list(:persona, 3, focus_group: focus_group) }
    let(:llm_data) do
      {
        "summary" => "Główny wniosek z dyskusji.",
        "strengths" => ["mocna strona 1", "mocna strona 2"],
        "weaknesses" => ["słaba strona 1"],
        "agreement_points" => ["wszyscy zgadzają się na X"],
        "persuasive_arguments" => ["argument o cenie przekonał 3 osoby"],
        "persistent_divisions" => ["młodzi vs starsi na temat gamifikacji"],
        "segment_insights" => ["marketingowcy doceniają personalizację"]
      }
    end

    subject(:subclass) do
      Class.new(described_class) do
        def call(focus_group:, data:, llm_model:, llm_provider:)
          create_recommendation(
            focus_group: focus_group,
            data: data,
            llm_model: llm_model,
            llm_provider: llm_provider
          )
        end
      end
    end

    it "creates Recommendation with summary, lists and computed rating_distribution" do
      personas.each_with_index do |p, i|
        create(:opinion, :round_one, persona: p, focus_group: focus_group, rating: i + 3)
      end

      rec = subclass.new.call(
        focus_group: focus_group,
        data: llm_data,
        llm_model: "claude-sonnet-4-6",
        llm_provider: "anthropic"
      )

      expect(rec).to be_persisted
      expect(rec.summary).to eq("Główny wniosek z dyskusji.")
      expect(rec.strengths).to eq(["mocna strona 1", "mocna strona 2"])
      expect(rec.weaknesses).to eq(["słaba strona 1"])
      expect(rec.rating_distribution).to eq({ "3" => 1, "4" => 1, "5" => 1 })
      expect(rec.agreement_points).to be_present
      expect(rec.persuasive_arguments).to be_present
      expect(rec.persistent_divisions).to be_present
      expect(rec.segment_insights).to be_present
      expect(rec.generated_at).to be_present
    end

    it "raises KeyError when required fields are missing" do
      expect {
        subclass.new.call(
          focus_group: focus_group,
          data: { "summary" => "tylko summary" },
          llm_model: "claude-sonnet-4-6",
          llm_provider: "anthropic"
        )
      }.to raise_error(KeyError)
    end
  end
end
