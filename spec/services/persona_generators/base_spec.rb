require "rails_helper"

RSpec.describe PersonaGenerators::Base do
  describe "#call" do
    it "raises NotImplementedError in the base class" do
      focus_group = create(:focus_group)
      expect {
        described_class.new.call(focus_group: focus_group, slot_demographics: {})
      }.to raise_error(NotImplementedError)
    end
  end

  describe "#create_persona (via subclass)" do
    let(:focus_group) { create(:focus_group) }
    let(:slot) { { "wiek" => "25-29", "plec" => "kobieta", "miejsce_zamieszkania" => "duze_miasto" } }
    let(:llm_data) do
      {
        "name" => "Anna Testowa",
        "description" => "Krótki opis testowej persony.",
        "demographics_extras" => { "miasto" => "Warszawa", "zawod" => "QA Engineer" },
        "traits" => {
          "wartosci" => ["jakość", "spójność"],
          "lifestyle" => "Pracuje zdalnie.",
          "obawy_zakupowe" => ["nie chcę się rozczarować"],
          "styl_komunikacji" => "Analityczny"
        }
      }
    end

    subject(:subclass) do
      Class.new(described_class) do
        def call(focus_group:, slot_demographics:, data:, llm_model:, llm_provider:)
          create_persona(
            focus_group: focus_group,
            slot_demographics: slot_demographics,
            data: data,
            llm_model: llm_model,
            llm_provider: llm_provider
          )
        end
      end
    end

    it "creates a Persona merging slot_demographics with demographics_extras" do
      persona = subclass.new.call(
        focus_group: focus_group,
        slot_demographics: slot,
        data: llm_data,
        llm_model: "gpt-4o-mini",
        llm_provider: "openai"
      )

      expect(persona).to be_persisted
      expect(persona.name).to eq("Anna Testowa")
      expect(persona.demographics).to include(
        "wiek" => "25-29",
        "plec" => "kobieta",
        "miejsce_zamieszkania" => "duze_miasto",
        "miasto" => "Warszawa",
        "zawod" => "QA Engineer"
      )
      expect(persona.traits).to eq(llm_data["traits"])
      expect(persona.llm_model).to eq("gpt-4o-mini")
      expect(persona.llm_provider).to eq("openai")
    end

    it "raises KeyError when required fields are missing" do
      expect {
        subclass.new.call(
          focus_group: focus_group,
          slot_demographics: slot,
          data: { "name" => "Bez opisu" },
          llm_model: "gpt-4o-mini",
          llm_provider: "openai"
        )
      }.to raise_error(KeyError)
    end
  end
end
