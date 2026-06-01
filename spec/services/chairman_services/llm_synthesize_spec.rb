require "rails_helper"

RSpec.describe ChairmanServices::LlmSynthesize, :vcr do
  let(:product) { create(:product, name: "Aplikacja do nauki języków", description: "Mobilna aplikacja do nauki języków obcych.") }
  let(:focus_group) { create(:focus_group, product: product, user: product.user, sample_size: 3, status: :synthesizing) }

  let!(:persona_a) do
    create(:persona, focus_group: focus_group, name: "Anna Kowalska",
           demographics: { "wiek" => "25-29", "plec" => "kobieta", "miasto" => "Warszawa", "zawod" => "Marketing Specialist" },
           traits: { "wartosci" => ["rozwój"], "lifestyle" => "9-17", "obawy_zakupowe" => ["subskrypcje"], "styl_komunikacji" => "Bezpośredni" },
           llm_model: "gpt-4o-mini", llm_provider: "openai")
  end

  let!(:persona_b) do
    create(:persona, focus_group: focus_group, name: "Marek Szymański",
           demographics: { "wiek" => "40-49", "plec" => "mezczyzna", "miasto" => "Łódź", "zawod" => "Kierownik logistyki" },
           traits: { "wartosci" => ["rodzina"], "lifestyle" => "8-18", "obawy_zakupowe" => ["czas"], "styl_komunikacji" => "Konkretny" },
           llm_model: "gpt-4o-mini", llm_provider: "openai")
  end

  let!(:persona_c) do
    create(:persona, focus_group: focus_group, name: "Karolina Nowak",
           demographics: { "wiek" => "30-34", "plec" => "kobieta", "miasto" => "Kraków", "zawod" => "Junior Accountant" },
           traits: { "wartosci" => ["awans"], "lifestyle" => "do 19", "obawy_zakupowe" => ["porażka"], "styl_komunikacji" => "Analityczny" },
           llm_model: "claude-haiku-4-5", llm_provider: "anthropic")
  end

  before do
    [persona_a, persona_b, persona_c].each do |p|
      create(:opinion, persona: p, focus_group: focus_group, round: 0, rating: 4,
             pros: "krótkie lekcje pasują do mojego dnia", cons: "boję się porzucenia", quote: "może tym razem zadziała")
    end
    create(:opinion, :round_one, persona: persona_a, focus_group: focus_group, rating: 4,
           pros: "5 minut realne", cons: "subskrypcje", quote: "spróbuję ale bez wiary",
           revised: false, revision_rationale: "")
    create(:opinion, :round_one, persona: persona_b, focus_group: focus_group, rating: 3,
           pros: "argument o tygodniowych celach mnie przekonał", cons: "wieczorami brak siły", quote: "tygodniowy plan ma sens",
           revised: true, revision_rationale: "Karolina pokazała że dzienne streaki to ślepa uliczka")
    create(:opinion, :round_one, persona: persona_c, focus_group: focus_group, rating: 5,
           pros: "tygodniowe cele dadzą rytm", cons: "cena ale OK", quote: "to ma sens",
           revised: false, revision_rationale: "")
  end

  describe "#call" do
    it "creates Recommendation with summary, lists and rating_distribution" do
      service = described_class.new(model: "claude-sonnet-4-6")
      rec = service.call(focus_group: focus_group)

      expect(rec).to be_persisted
      expect(rec.focus_group).to eq(focus_group)
      expect(rec.summary).to be_present
      expect(rec.strengths).to be_an(Array).and(be_present)
      expect(rec.weaknesses).to be_an(Array).and(be_present)
      expect(rec.agreement_points).to be_an(Array)
      expect(rec.persuasive_arguments).to be_an(Array)
      expect(rec.persistent_divisions).to be_an(Array)
      expect(rec.segment_insights).to be_an(Array)
      expect(rec.rating_distribution).to eq({ "3" => 1, "4" => 1, "5" => 1 })
      expect(rec.generated_at).to be_present
    end
  end
end
