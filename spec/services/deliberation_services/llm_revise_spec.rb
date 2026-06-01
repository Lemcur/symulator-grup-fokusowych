require "rails_helper"

RSpec.describe DeliberationServices::LlmRevise, :vcr do
  let(:product) { create(:product, name: "Aplikacja do nauki języków", description: "Mobilna aplikacja do nauki języków obcych.") }
  let(:focus_group) { create(:focus_group, product: product, user: product.user, sample_size: 3, status: :deliberating) }

  let(:persona) do
    create(:persona,
           focus_group: focus_group,
           name: "Anna Kowalska",
           description: "28-letnia marketing specialist z Warszawy, próbuje uczyć się hiszpańskiego od dwóch lat bez sukcesu.",
           demographics: { "wiek" => "25-29", "plec" => "kobieta", "miasto" => "Warszawa", "zawod" => "Marketing Specialist" },
           traits: { "wartosci" => ["rozwój zawodowy"], "lifestyle" => "9-17 praca", "obawy_zakupowe" => ["kolejna subskrypcja"], "styl_komunikacji" => "Bezpośredni, ironiczny" },
           llm_model: "gpt-4o-mini",
           llm_provider: "openai")
  end

  let(:peer_a) do
    create(:persona, focus_group: focus_group, name: "Marek Szymański",
           demographics: { "wiek" => "40-49", "plec" => "mezczyzna", "miasto" => "Łódź", "zawod" => "Kierownik logistyki" },
           traits: { "wartosci" => ["rodzina"], "lifestyle" => "8-18 praca", "obawy_zakupowe" => ["brak czasu"], "styl_komunikacji" => "Konkretny" })
  end

  let(:peer_b) do
    create(:persona, focus_group: focus_group, name: "Karolina Nowak",
           demographics: { "wiek" => "30-34", "plec" => "kobieta", "miasto" => "Kraków", "zawod" => "Junior Accountant" },
           traits: { "wartosci" => ["awans"], "lifestyle" => "do 19 praca", "obawy_zakupowe" => ["zapłacę i rzucę"], "styl_komunikacji" => "Analityczny" })
  end

  let!(:own_round_zero) do
    create(:opinion, persona: persona, focus_group: focus_group, round: 0, rating: 4,
           pros: "5 minut to realne w moim grafiku", cons: "boję się kolejnej subskrypcji której nie wykorzystam", quote: "może tym razem się uda")
  end

  let!(:peer_round_zero_a) do
    create(:opinion, persona: peer_a, focus_group: focus_group, round: 0, rating: 2,
           pros: "krótkie lekcje", cons: "nie mam czasu nawet na 5 minut", quote: "wieczorami jestem skończony")
  end

  let!(:peer_round_zero_b) do
    create(:opinion, persona: peer_b, focus_group: focus_group, round: 0, rating: 5,
           pros: "tygodniowe cele dadzą rytm", cons: "cena", quote: "tygodniowy plan zamiast dziennego streaka to dobre rozwiązanie")
  end

  describe "#call" do
    it "creates Opinion(round=1) with revised flag and rationale" do
      peers = focus_group.opinions.where(round: 0).where.not(persona_id: persona.id).includes(:persona)
      service = described_class.new(model: "gpt-4o-mini")

      opinion = service.call(persona: persona, peer_opinions: peers)

      expect(opinion).to be_persisted
      expect(opinion.round).to eq(1)
      expect(opinion).to be_collected
      expect(opinion.rating).to be_between(1, 5)
      expect(opinion.pros).to be_present
      expect(opinion.cons).to be_present
      expect(opinion.quote).to be_present
      expect([true, false]).to include(opinion.revised)
      expect(opinion.revision_rationale).to be_a(String)
    end
  end
end
