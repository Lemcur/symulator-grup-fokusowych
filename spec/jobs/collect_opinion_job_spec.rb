require "rails_helper"

RSpec.describe CollectOpinionJob, :vcr do
  let(:product) { create(:product, name: "Aplikacja do nauki języków", description: "Mobilna aplikacja do nauki języków obcych.") }
  let(:focus_group) do
    create(:focus_group,
           product: product,
           user: product.user,
           sample_size: 2,
           status: :collecting_opinions)
  end
  let!(:personas) do
    create_list(:persona, 2, focus_group: focus_group, llm_model: "gpt-4o-mini", llm_provider: "openai")
  end

  describe "#perform" do
    it "creates an Opinion(round=0) for the given persona" do
      expect {
        described_class.perform_now(personas.first.id)
      }.to change { focus_group.reload.opinions.where(round: 0).count }.from(0).to(1)

      opinion = personas.first.opinions.where(round: 0).first
      expect(opinion).to be_collected
      expect(opinion.rating).to be_between(1, 5)
    end

    it "transitions focus_group to deliberating when last opinion collected" do
      described_class.perform_now(personas.first.id)
      expect(focus_group.reload.status).to eq("collecting_opinions")

      described_class.perform_now(personas.last.id)
      expect(focus_group.reload.status).to eq("deliberating")
    end

    it "does not run when focus_group is not in collecting_opinions status" do
      focus_group.update!(status: :deliberating)

      expect {
        described_class.perform_now(personas.first.id)
      }.not_to change(Opinion, :count)
    end

    it "enqueues DeliberateJob for each persona after last round=0 collected" do
      described_class.perform_now(personas.first.id)
      expect {
        described_class.perform_now(personas.last.id)
      }.to have_enqueued_job(DeliberateJob).exactly(2).times
    end
  end
end
