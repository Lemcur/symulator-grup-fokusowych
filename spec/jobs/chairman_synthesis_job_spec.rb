require "rails_helper"

RSpec.describe ChairmanSynthesisJob, :vcr do
  let(:product) { create(:product, name: "Aplikacja do nauki języków", description: "Mobilna aplikacja do nauki języków obcych.") }
  let(:focus_group) { create(:focus_group, product: product, user: product.user, sample_size: 3, status: :synthesizing) }

  let!(:personas) do
    [
      create(:persona, focus_group: focus_group, name: "Anna Kowalska",
             demographics: { "wiek" => "25-29", "plec" => "kobieta", "miasto" => "Warszawa", "zawod" => "Marketing Specialist" },
             traits: { "wartosci" => ["rozwój"], "lifestyle" => "9-17", "obawy_zakupowe" => ["subskrypcje"], "styl_komunikacji" => "Bezpośredni" },
             llm_model: "gpt-4o-mini", llm_provider: "openai"),
      create(:persona, focus_group: focus_group, name: "Marek Szymański",
             demographics: { "wiek" => "40-49", "plec" => "mezczyzna", "miasto" => "Łódź", "zawod" => "Kierownik logistyki" },
             traits: { "wartosci" => ["rodzina"], "lifestyle" => "8-18", "obawy_zakupowe" => ["czas"], "styl_komunikacji" => "Konkretny" },
             llm_model: "gpt-4o-mini", llm_provider: "openai"),
      create(:persona, focus_group: focus_group, name: "Karolina Nowak",
             demographics: { "wiek" => "30-34", "plec" => "kobieta", "miasto" => "Kraków", "zawod" => "Junior Accountant" },
             traits: { "wartosci" => ["awans"], "lifestyle" => "do 19", "obawy_zakupowe" => ["porażka"], "styl_komunikacji" => "Analityczny" },
             llm_model: "claude-haiku-4-5", llm_provider: "anthropic")
    ]
  end

  before do
    personas.each_with_index do |p, i|
      create(:opinion, persona: p, focus_group: focus_group, round: 0, rating: i + 3,
             pros: "krótkie lekcje", cons: "obawiam się porzucenia", quote: "spróbuję")
      create(:opinion, :round_one, persona: p, focus_group: focus_group, rating: i + 3,
             pros: "po deliberacji", cons: "nadal obawy", quote: "tak",
             revised: i.even?, revision_rationale: i.even? ? "argument X mnie przekonał" : "")
    end
  end

  describe "#perform" do
    it "creates Chairman and Recommendation and transitions focus_group to completed" do
      expect {
        described_class.perform_now(focus_group.id)
      }.to change { focus_group.reload.recommendation }.from(nil)
        .and change(Chairman, :count).by(1)

      expect(focus_group.reload.status).to eq("completed")
      expect(focus_group.completed_at).to be_present
      expect(focus_group.synthesis_started_at).to be_present
      expect(focus_group.chairman.llm_model).to eq("claude-sonnet-4-6")
      expect(focus_group.recommendation.summary).to be_present
    end

    it "does not run when focus_group is not in synthesizing status" do
      focus_group.update!(status: :completed)

      expect {
        described_class.perform_now(focus_group.id)
      }.not_to change(Recommendation, :count)
    end
  end
end
