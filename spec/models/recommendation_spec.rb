require "rails_helper"

RSpec.describe Recommendation, type: :model do
  describe "validations" do
    it "rejects two recommendations for the same focus_group" do
      fg = create(:focus_group)
      create(:recommendation, focus_group: fg)
      dup = build(:recommendation, focus_group: fg)

      expect(dup).not_to be_valid
      expect(dup.errors[:focus_group_id]).to be_present
    end
  end

  describe "jsonb fields" do
    it "stores Hall-specific structural fields" do
      rec = create(:recommendation,
        agreement_points: ["wszyscy doceniają jakość"],
        persuasive_arguments: ["argument o cenie przekonał 5 osób"],
        persistent_divisions: ["młodzi vs starsi co do gwarancji"]
      )

      expect(rec.agreement_points).to eq(["wszyscy doceniają jakość"])
      expect(rec.persuasive_arguments.size).to eq(1)
      expect(rec.persistent_divisions.first).to include("młodzi vs starsi")
    end

    it "stores rating_distribution as a hash keyed by rating value" do
      rec = create(:recommendation, rating_distribution: { "1" => 0, "5" => 10 })
      expect(rec.rating_distribution["5"]).to eq(10)
    end
  end
end
