require "rails_helper"

RSpec.describe OpinionCollectors::LlmBasic, :vcr do
  let(:product) { create(:product, name: "Aplikacja do nauki języków", description: "Mobilna aplikacja do nauki języków obcych.") }
  let(:focus_group) { create(:focus_group, product: product, user: product.user, sample_size: 1) }
  let(:persona) do
    create(:persona,
           focus_group: focus_group,
           name: "Anna Kowalska",
           description: "28-letnia marketing specialist z Warszawy, próbuje uczyć się hiszpańskiego od dwóch lat bez sukcesu.",
           demographics: { "wiek" => "25-29", "plec" => "kobieta", "miasto" => "Warszawa", "zawod" => "Marketing Specialist" },
           traits: {
             "wartosci" => ["rozwój zawodowy", "work-life balance"],
             "lifestyle" => "Pracuje 9-17, wieczorami siłownia lub Netflix.",
             "obawy_zakupowe" => ["kolejna subskrypcja której nie wykorzystam"],
             "styl_komunikacji" => "Bezpośredni, lekko ironiczny"
           },
           llm_model: "gpt-4o-mini",
           llm_provider: "openai")
  end

  describe "#call" do
    it "collects an Opinion(round=0) via real LLM call" do
      collector = described_class.new(model: "gpt-4o-mini")
      opinion = collector.call(persona: persona)

      expect(opinion).to be_persisted
      expect(opinion.round).to eq(0)
      expect(opinion).to be_collected
      expect(opinion.rating).to be_between(1, 5)
      expect(opinion.pros).to be_present
      expect(opinion.cons).to be_present
      expect(opinion.quote).to be_present
      expect(opinion.persona).to eq(persona)
      expect(opinion.focus_group).to eq(focus_group)
    end
  end
end
