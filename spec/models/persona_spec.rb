require "rails_helper"

RSpec.describe Persona, type: :model do
  describe "validations" do
    it "requires name" do
      persona = build(:persona, name: nil)
      expect(persona).not_to be_valid
      expect(persona.errors[:name]).to be_present
    end

    it "requires description" do
      persona = build(:persona, description: nil)
      expect(persona).not_to be_valid
      expect(persona.errors[:description]).to be_present
    end
  end

  describe "opinion helpers" do
    let(:persona) { create(:persona) }

    it "returns the round=0 opinion via round_zero_opinion" do
      r0 = create(:opinion, persona: persona, focus_group: persona.focus_group, round: 0)
      create(:opinion, :round_one, persona: persona, focus_group: persona.focus_group)

      expect(persona.round_zero_opinion).to eq(r0)
    end

    it "returns the round=1 opinion via round_one_opinion" do
      create(:opinion, persona: persona, focus_group: persona.focus_group, round: 0)
      r1 = create(:opinion, :round_one, persona: persona, focus_group: persona.focus_group)

      expect(persona.round_one_opinion).to eq(r1)
    end

    it "returns nil when no opinion exists for the round" do
      expect(persona.round_zero_opinion).to be_nil
      expect(persona.round_one_opinion).to be_nil
    end
  end

  describe "cascading delete" do
    it "destroys opinions when persona is destroyed" do
      persona = create(:persona)
      create(:opinion, persona: persona, focus_group: persona.focus_group)
      create(:opinion, :round_one, persona: persona, focus_group: persona.focus_group)

      expect { persona.destroy }.to change(Opinion, :count).by(-2)
    end
  end
end
