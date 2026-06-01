module DeliberationServices
  class LlmRevise < Base
    def initialize(model:)
      @client = LlmClient.new(model: model)
    end

    def call(persona:, peer_opinions:)
      data = @client.ask(prompt(persona, peer_opinions), schema: DeliberationSchema)

      create_revised_opinion(
        persona: persona,
        data: data,
        llm_model: @client.model,
        llm_provider: @client.provider.to_s
      )
    end

    private

    def prompt(persona, peer_opinions)
      own = persona.round_zero_opinion
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

        PRODUKT:
        #{product.name}
        #{product.description}

        TWOJA POPRZEDNIA OPINIA (przed dyskusją z grupą):
        - Ocena: #{own.rating}/5
        - Plusy: #{own.pros}
        - Minusy: #{own.cons}
        - Twój cytat: "#{own.quote}"

        OPINIE INNYCH UCZESTNIKÓW GRUPY (po wstępnej rundzie):
        #{format_peer_opinions(peer_opinions)}

        Twoje zadanie: po wysłuchaniu opinii innych uczestników, ZADECYDUJ czy zmieniasz swoją opinię.

        ZASADY:
        - Zmieniasz TYLKO jeśli czyjś konkretny argument naprawdę Cię przekonał — nie zmieniaj "bo wszyscy mówią"
        - Możesz wzmocnić swoją pierwotną opinię jeśli ktoś podał argument który potwierdził Twoje wątpliwości lub Twoje plusy
        - Pamiętaj o swojej osobowości — osoba sceptyczna pozostaje sceptyczna chyba że ktoś podał MOCNY konkretny argument zmieniający perspektywę
        - Jeśli rewidujesz: rating, pros, cons LUB quote powinny się rzeczywiście zmienić; revision_rationale wyjaśnia który argument Cię przekonał
        - Jeśli nie rewidujesz: zwróć te same wartości co w pierwotnej opinii, revised=false, revision_rationale=""

        Zwróć JSON zgodny ze schematem.
      PROMPT
    end

    def format_peer_opinions(peer_opinions)
      peer_opinions.map.with_index(1) do |op, i|
        <<~PEER
          #{i}. #{op.persona.name} (#{op.persona.demographics['miasto']}, #{op.persona.demographics['zawod']}) — ocena #{op.rating}/5
             Plusy: #{op.pros}
             Minusy: #{op.cons}
             Cytat: "#{op.quote}"
        PEER
      end.join("\n")
    end
  end
end
