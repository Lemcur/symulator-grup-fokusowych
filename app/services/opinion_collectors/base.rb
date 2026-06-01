module OpinionCollectors
  class Base
    def call(persona:)
      raise NotImplementedError
    end

    private

    def create_opinion(persona:, data:, llm_model:, llm_provider:)
      Opinion.create!(
        persona: persona,
        focus_group: persona.focus_group,
        round: 0,
        status: :collected,
        rating: data.fetch("rating").to_i,
        pros: data.fetch("pros"),
        cons: data.fetch("cons"),
        quote: data.fetch("quote"),
        raw_response: data.merge("llm_model" => llm_model, "llm_provider" => llm_provider)
      )
    end
  end
end
