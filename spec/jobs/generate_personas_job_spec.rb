require "rails_helper"

RSpec.describe GeneratePersonasJob, :vcr do
  let(:product) { create(:product, name: "Aplikacja do nauki języków", description: "Mobilna aplikacja do nauki języków obcych.") }
  let(:focus_group) do
    create(:focus_group,
           product: product,
           user: product.user,
           sample_size: 2,
           status: :pending,
           generation_mode: :slots,
           target_demographics: [
             { "count" => 1, "wiek" => "25-29", "plec" => "kobieta", "miejsce_zamieszkania" => "duze_miasto" },
             { "count" => 1, "wiek" => "30-34", "plec" => "kobieta", "miejsce_zamieszkania" => "duze_miasto" }
           ])
  end

  describe "#perform" do
    it "generates sample_size personas sequentially and transitions status to collecting_opinions" do
      expect {
        described_class.perform_now(focus_group.id)
      }.to change { focus_group.reload.personas.count }.from(0).to(2)

      expect(focus_group.reload.status).to eq("collecting_opinions")
      expect(focus_group.started_at).to be_present
      expect(focus_group.personas.pluck(:name).uniq.size).to eq(2)
    end

    it "does not start when focus_group is not in pending status" do
      focus_group.update!(status: :generating_personas)

      expect {
        described_class.perform_now(focus_group.id)
      }.not_to change { focus_group.reload.personas.count }
    end

    it "rotates llm_model by index according to MODEL_SPLIT" do
      described_class.perform_now(focus_group.id)

      models = focus_group.reload.personas.order(:created_at).pluck(:llm_model)
      expect(models).to eq(GeneratePersonasJob::MODEL_SPLIT.first(2))
    end

    it "enqueues CollectOpinionJob for each generated persona" do
      expect {
        described_class.perform_now(focus_group.id)
      }.to have_enqueued_job(CollectOpinionJob).exactly(2).times
    end
  end
end
