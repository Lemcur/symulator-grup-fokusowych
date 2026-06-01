module PersonaGenerators
  class Base
    def call(focus_group:, slot_demographics:, previous_context: "")
      raise NotImplementedError
    end

    private

    def create_persona(focus_group:, slot_demographics:, data:, llm_model:, llm_provider:)
      demographics = slot_demographics.merge(data.fetch("demographics_extras", {}))

      Persona.create!(
        focus_group: focus_group,
        name: data.fetch("name"),
        description: data.fetch("description"),
        demographics: demographics,
        traits: data.fetch("traits"),
        llm_model: llm_model,
        llm_provider: llm_provider
      )
    end
  end
end
