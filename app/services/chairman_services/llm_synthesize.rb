module ChairmanServices
  class LlmSynthesize < Base
    def initialize(model:)
      @client = LlmClient.new(model: model)
    end

    def call(focus_group:)
      data = @client.ask(prompt(focus_group), schema: RecommendationSchema)

      create_recommendation(
        focus_group: focus_group,
        data: data,
        llm_model: @client.model,
        llm_provider: @client.provider.to_s
      )
    end

    private

    def prompt(focus_group)
      product = focus_group.product
      personas = focus_group.personas.order(:created_at)

      <<~PROMPT
        Jesteś moderatorem (chairmanem) polskiej grupy fokusowej. Twoim zadaniem jest syntetyczne podsumowanie wyników dyskusji w formie raportu badawczego.

        PRODUKT:
        #{product.name}
        #{product.description}

        BRIEF SESJI:
        Sample size: #{focus_group.sample_size} osób
        Target demographics: #{focus_group.target_demographics.to_json}

        UCZESTNICY (#{personas.count} osób):
        #{format_participants(personas)}

        FINALNE OPINIE PO DELIBERACJI (round=1):
        #{format_round_one_opinions(focus_group)}

        REWIZJE (kto i dlaczego zmienił zdanie po deliberacji):
        #{format_revisions(focus_group)}

        TWOJE ZADANIE:
        Stwórz syntetyczny raport badawczy. Pamiętaj:
        - Cytuj konkretne osoby przy insights ("Anna (Warszawa, marketing): ...")
        - W persuasive_arguments wskaż konkretne argumenty które realnie przekonały innych do zmiany — to dane do replikacji w innych badaniach
        - W persistent_divisions pokaż gdzie panel pozostał podzielony pomimo dyskusji — to obszary wymagające dalszego badania
        - W segment_insights wyciągnij wzorce między demografiami (np. "młodzi marketingowcy doceniają gamifikację, nauczyciele jej nie ufają")
        - Summary: 3-4 zdania głównego wniosku jak dla decydenta produktowego

        Zwróć JSON zgodny ze schematem.
      PROMPT
    end

    def format_participants(personas)
      personas.map.with_index(1) do |p, i|
        "#{i}. #{p.name} — #{p.demographics['wiek']}, #{p.demographics['miasto']}, #{p.demographics['zawod']}"
      end.join("\n")
    end

    def format_round_one_opinions(focus_group)
      focus_group.opinions.round_one.includes(:persona).map.with_index(1) do |op, i|
        persona = op.persona
        <<~OP
          #{i}. #{persona.name} (#{persona.demographics['miasto']}, #{persona.demographics['zawod']}) — ocena #{op.rating}/5
             Plusy: #{op.pros}
             Minusy: #{op.cons}
             Cytat: "#{op.quote}"
        OP
      end.join("\n")
    end

    def format_revisions(focus_group)
      revised_opinions = focus_group.opinions.round_one.where(revised: true).includes(:persona)
      return "Brak — żaden z uczestników nie zmienił zdania po deliberacji." if revised_opinions.empty?

      revised_opinions.map do |op|
        own_zero = op.persona.round_zero_opinion
        delta = "round0=#{own_zero&.rating}/5 → round1=#{op.rating}/5"
        "- #{op.persona.name}: #{delta}; powód: #{op.revision_rationale}"
      end.join("\n")
    end
  end
end
