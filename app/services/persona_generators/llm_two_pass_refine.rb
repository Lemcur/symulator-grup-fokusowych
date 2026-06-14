module PersonaGenerators
  class LlmTwoPassRefine < Base
    FEW_SHOT_EXAMPLES = <<~EXAMPLES
      PRZYKŁAD 1 - DOBRZE napisana persona:
      {
        "name": "Anna Kowalska",
        "description": "28-letnia specjalistka ds. marketingu w warszawskiej agencji. Mieszka z partnerem na Mokotowie. Próbuje od dwóch lat opanować hiszpański - kupiła kilka kursów, żaden nie wszedł jej w nawyk. Trochę się tego wstydzi.",
        "demographics": {
          "wiek": "25-29",
          "plec": "kobieta",
          "miejsce_zamieszkania": "duze_miasto",
          "miasto": "Warszawa",
          "zawod": "Marketing Specialist"
        },
        "traits": {
          "wartosci": ["rozwój zawodowy", "work-life balance", "relacje"],
          "lifestyle": "Pracuje 9-17, wieczorami siłownia lub Netflix. Hiszpański chce w wakacje na wyjazd do Walencji.",
          "obawy_zakupowe": ["nie chcę kolejnej subskrypcji której nie wykorzystam", "boję się że to znowu chwilowy zapał"],
          "styl_komunikacji": "Bezpośredni, lekko ironiczny"
        }
      }

      PRZYKŁAD 2 - DOBRZE napisana persona:
      {
        "name": "Marek Szymański",
        "description": "42-letni kierownik logistyki w firmie spedycyjnej pod Łodzią. Żona, dwoje dzieci (8 i 12 lat). Awansował dwa lata temu, podstawowy angielski ledwo wystarcza mu na maile z dostawcami z Niemiec. Wieczorami zmęczony, ale szef coraz częściej zwraca uwagę.",
        "demographics": {
          "wiek": "40-49",
          "plec": "mezczyzna",
          "miejsce_zamieszkania": "srednie_miasto",
          "miasto": "Łódź",
          "zawod": "Kierownik logistyki"
        },
        "traits": {
          "wartosci": ["bezpieczeństwo finansowe", "rodzina", "praktyczność"],
          "lifestyle": "Praca 8-18, weekendy z rodziną. Czasem trening piłki nożnej. Telefon głównie do połączeń i WhatsAppa.",
          "obawy_zakupowe": ["nie mam czasu na naukę 30 min dziennie", "wątpię czy app nauczy mnie tego co potrzebuję - terminologii spedycyjnej"],
          "styl_komunikacji": "Konkretny, oszczędny, sceptyczny"
        }
      }
    EXAMPLES

    def initialize(model:)
      @client = LlmClient.new(model: model)
    end

    def call(focus_group:, slot_demographics:, previous_context: "")
      candidate = generate_candidate(focus_group, slot_demographics, previous_context)
      refined = critique_and_refine(focus_group, candidate)

      create_persona(
        focus_group: focus_group,
        slot_demographics: slot_demographics,
        data: refined,
        llm_model: @client.model,
        llm_provider: @client.provider.to_s
      )
    end

    private

    def generate_candidate(focus_group, slot_demographics, previous_context)
      @client.ask(generation_prompt(focus_group, slot_demographics, previous_context), schema: PersonaSchema)
    end

    def critique_and_refine(focus_group, candidate)
      @client.ask(refinement_prompt(focus_group, candidate), schema: PersonaSchema)
    end

    def generation_prompt(focus_group, slot_demographics, previous_context)
      brief_block = focus_group.brief_summary.present? ? "OPIS DOCELOWEJ GRUPY (od badacza):\n#{focus_group.brief_summary}\n\n" : ""
      requirements_block = focus_group.additional_requirements.present? ? "WYMAGANIA DODATKOWE (kompetencje i kryteria wykluczające - KAŻDA persona musi je spełniać):\n#{focus_group.additional_requirements}\n\n" : ""
      slot_block = slot_demographics.any? ? "OGRANICZENIA DEMOGRAFICZNE (MUSISZ ZACHOWAĆ):\n#{format_slot(slot_demographics)}\n\n" : "OGRANICZENIA DEMOGRAFICZNE: brak - dobierz demografię samodzielnie zgodnie z opisem grupy.\n\n"

      <<~PROMPT
        Jesteś projektantem person badawczych dla polskiej grupy fokusowej.

        PRODUKT: #{focus_group.product.name}
        OPIS PRODUKTU: #{focus_group.product.description}

        #{brief_block}#{requirements_block}#{slot_block}#{previous_context}

        PRZYKŁADY DOBRZE NAPISANYCH PERSON (do naśladowania stylu i głębokości):
        #{FEW_SHOT_EXAMPLES}

        Wymyśl JEDNĄ realistyczną personę zgodną z ograniczeniami demograficznymi.
        WAŻNE:
        - nie idealizuj - persony mają wady, mieszane uczucia, ograniczenia budżetowe
        - konkretne miasto, zawód, kontekst życiowy (nie ogólnie "pracuje w korpo")
        - opisuj językiem prawdopodobnym dla tej osoby (kierownik logistyki z Łodzi mówi inaczej niż Marketing Specialist z Warszawy)
        - zachowaj proporcje: 3-4 zdania backstory, 3-5 wartości, 2-3 obawy zakupowe

        Zwróć JSON zgodny ze schematem.
      PROMPT
    end

    def refinement_prompt(focus_group, candidate)
      <<~PROMPT
        Oto kandydat na personę dla badania produktu "#{focus_group.product.name}":

        #{candidate.to_json}

        TWOJE ZADANIE: krytycznie oceń tę personę i POPRAW ją.

        Sprawdź każdy z punktów:
        1. Czy jest zbyt idealizowana? (np. "kochająca rodzinę + rozwinięta zawodowo + ekologicznie świadoma" = TAK, popraw)
        2. Czy ma realistyczne wady, ograniczenia budżetowe, niepewności, sprzeczności?
        3. Czy detail (miasto, zawód, kontekst) jest konkretny czy generyczny?
        4. Czy styl komunikacji odzwierciedla jej tło demograficzne i zawodowe?
        5. Czy obawy zakupowe są specyficzne dla TEGO produktu, nie generyczne ("czy będzie warte ceny")?

        Zwróć POPRAWIONĄ wersję w tym samym JSON schemacie.
        Zachowaj te same wartości pól demographics (wiek, płeć, miejsce_zamieszkania).
        Możesz zmienić imię, miasto, zawód, opis, wszystkie traits.
      PROMPT
    end

    def format_slot(slot)
      slot.map { |k, v| "- #{k}: #{v}" }.join("\n")
    end
  end
end
