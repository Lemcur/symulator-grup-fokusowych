module OpinionCollectors
  class LlmBasic < Base
    def initialize(model:)
      @client = LlmClient.new(model: model)
    end

    def call(persona:)
      data = @client.ask(prompt(persona), schema: OpinionSchema)

      create_opinion(
        persona: persona,
        data: data,
        llm_model: @client.model,
        llm_provider: @client.provider.to_s
      )
    end

    private

    def prompt(persona)
      product = persona.focus_group.product

      <<~PROMPT
        Wcielasz się w realnego respondenta polskiej grupy fokusowej. Odpowiadasz JAKO ta osoba.

        IMIĘ: #{persona.name}
        OPIS: #{persona.description}
        DEMOGRAFIA: #{persona.demographics.to_json}
        WARTOŚCI: #{Array(persona.traits['wartosci']).join(', ')}
        LIFESTYLE: #{persona.traits['lifestyle']}
        OBAWY ZAKUPOWE: #{Array(persona.traits['obawy_zakupowe']).join('; ')}
        STYL KOMUNIKACJI: #{persona.traits['styl_komunikacji']}

        PRODUKT DO OCENY:
        #{product.name}
        #{product.description}

        Twoje zadanie: WYPOWIEDZ SIĘ na temat tego produktu zgodnie z osobowością z brief'u powyżej.

        - Oceń produkt w skali 1-5 (1=zdecydowanie nie kupię/nie użyję, 5=zdecydowanie tak)
        - Wymień konkretne PLUSY ważne dla CIEBIE - nie ogólne ("dobra aplikacja"), tylko specyficzne ("po godzinach mam tylko 15 minut zanim zasnę")
        - Wymień konkretne MINUSY / obawy / zastrzeżenia jakie masz wobec tego produktu
        - Daj jeden charakterystyczny CYTAT w pierwszej osobie - coś co naprawdę powiedziałabyś/powiedziałbyś o tym produkcie

        Mów stylu komunikacji typowym dla swojej osoby. Możesz być sceptyczny/sceptyczna. Nie idealizuj.

        Zwróć JSON zgodny ze schematem.
      PROMPT
    end
  end
end
