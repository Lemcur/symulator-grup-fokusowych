require "rails_helper"

RSpec.describe Chairman, type: :model do
  describe "walidacje" do
    it "wymaga llm_model" do
      chairman = build(:chairman, llm_model: nil)
      expect(chairman).not_to be_valid
      expect(chairman.errors[:llm_model]).to be_present
    end

    it "blokuje dwóch chairmanów dla jednej sesji" do
      fg = create(:focus_group)
      create(:chairman, focus_group: fg)
      dup = build(:chairman, focus_group: fg)

      expect(dup).not_to be_valid
      expect(dup.errors[:focus_group_id]).to be_present
    end
  end
end
