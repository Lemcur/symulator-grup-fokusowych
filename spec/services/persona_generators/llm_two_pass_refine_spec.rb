require "rails_helper"

RSpec.describe PersonaGenerators::LlmTwoPassRefine, :vcr do
  let(:product) { create(:product, name: "Aplikacja do nauki języków", description: "Mobilna aplikacja do nauki języków obcych.") }
  let(:focus_group) { create(:focus_group, product: product, user: product.user, sample_size: 12) }
  let(:slot) { { "wiek" => "25-29", "plec" => "kobieta", "miejsce_zamieszkania" => "duze_miasto" } }

  describe "#call" do
    it "generates a Persona via a real LLM call (gpt-4o-mini)" do
      generator = described_class.new(model: "gpt-4o-mini")
      persona = generator.call(focus_group: focus_group, slot_demographics: slot)

      expect(persona).to be_persisted
      expect(persona.name).to be_present
      expect(persona.description.length).to be > 50
      expect(persona.demographics["wiek"]).to eq("25-29")
      expect(persona.demographics["plec"]).to eq("kobieta")
      expect(persona.demographics["miejsce_zamieszkania"]).to eq("duze_miasto")
      expect(persona.demographics["miasto"]).to be_present
      expect(persona.demographics["zawod"]).to be_present
      expect(persona.traits["wartosci"]).to be_an(Array).and(be_present)
      expect(persona.traits["obawy_zakupowe"]).to be_an(Array).and(be_present)
      expect(persona.llm_model).to eq("gpt-4o-mini")
      expect(persona.llm_provider).to eq("openai")
    end

    it "injects previous_context so the second persona differs from the first" do
      generator = described_class.new(model: "gpt-4o-mini")
      first = generator.call(focus_group: focus_group, slot_demographics: slot)
      previous = "DOTYCHCZAS ZAPROJEKTOWANI:\n1. #{first.name} (#{first.demographics['miasto']}, #{first.demographics['zawod']})\nUnikaj powtórzenia."

      second = generator.call(focus_group: focus_group, slot_demographics: slot, previous_context: previous)

      expect(second.name).not_to eq(first.name)
    end
  end
end
