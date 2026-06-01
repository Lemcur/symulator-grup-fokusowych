require "rails_helper"

RSpec.describe DeliberateJob, :vcr do
  let(:product) { create(:product, name: "Aplikacja do nauki języków", description: "Mobilna aplikacja do nauki języków obcych.") }
  let(:focus_group) { create(:focus_group, product: product, user: product.user, sample_size: 2, status: :deliberating) }

  let!(:persona_a) do
    create(:persona, focus_group: focus_group, name: "Anna Kowalska",
           demographics: { "wiek" => "25-29", "plec" => "kobieta", "miasto" => "Warszawa", "zawod" => "Marketing Specialist" },
           traits: { "wartosci" => ["rozwój"], "lifestyle" => "9-17", "obawy_zakupowe" => ["subskrypcje"], "styl_komunikacji" => "Bezpośredni" },
           llm_model: "gpt-4o-mini",
           llm_provider: "openai")
  end

  let!(:persona_b) do
    create(:persona, focus_group: focus_group, name: "Marek Szymański",
           demographics: { "wiek" => "40-49", "plec" => "mezczyzna", "miasto" => "Łódź", "zawod" => "Kierownik logistyki" },
           traits: { "wartosci" => ["rodzina"], "lifestyle" => "8-18", "obawy_zakupowe" => ["czas"], "styl_komunikacji" => "Konkretny" },
           llm_model: "gpt-4o-mini",
           llm_provider: "openai")
  end

  let!(:round_zero_a) do
    create(:opinion, persona: persona_a, focus_group: focus_group, round: 0, rating: 4,
           pros: "5 minut to realne", cons: "boję się kolejnej subskrypcji", quote: "może tym razem zadziała")
  end

  let!(:round_zero_b) do
    create(:opinion, persona: persona_b, focus_group: focus_group, round: 0, rating: 2,
           pros: "krótkie lekcje", cons: "wieczorami brak siły", quote: "po pracy nie ogarniam")
  end

  describe "#perform" do
    it "creates Opinion(round=1) for the given persona" do
      expect {
        described_class.perform_now(persona_a.id)
      }.to change { focus_group.reload.opinions.where(round: 1).count }.from(0).to(1)

      revised = persona_a.opinions.where(round: 1).first
      expect(revised).to be_collected
      expect(revised.rating).to be_between(1, 5)
    end

    it "transitions focus_group to synthesizing when last round=1 opinion done" do
      described_class.perform_now(persona_a.id)
      expect(focus_group.reload.status).to eq("deliberating")

      described_class.perform_now(persona_b.id)
      expect(focus_group.reload.status).to eq("synthesizing")
    end

    it "does not run when focus_group is not in deliberating status" do
      focus_group.update!(status: :synthesizing)

      expect {
        described_class.perform_now(persona_a.id)
      }.not_to change(Opinion, :count)
    end

    it "enqueues ChairmanSynthesisJob after last round=1 collected" do
      described_class.perform_now(persona_a.id)
      expect {
        described_class.perform_now(persona_b.id)
      }.to have_enqueued_job(ChairmanSynthesisJob).exactly(1).times
    end
  end

  describe "#peer_opinions_for" do
    it "excludes the persona's own round=0 opinion (anti-anchoring)" do
      peers = described_class.new.peer_opinions_for(persona_a)

      expect(peers.map(&:persona_id)).to contain_exactly(persona_b.id)
      expect(peers.map(&:persona_id)).not_to include(persona_a.id)
    end
  end
end
