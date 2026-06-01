require "rails_helper"

RSpec.describe Opinion, type: :model do
  describe "validations" do
    it "requires round to be 0 or 1" do
      [0, 1].each do |r|
        expect(build(:opinion, round: r)).to be_valid
      end
      [-1, 2, nil].each do |r|
        expect(build(:opinion, round: r)).not_to be_valid
      end
    end

    describe "uniqueness of [persona, round]" do
      it "allows one opinion per round for the same persona" do
        persona = create(:persona)
        create(:opinion, persona: persona, focus_group: persona.focus_group, round: 0)
        r1 = build(:opinion, :round_one, persona: persona, focus_group: persona.focus_group)
        expect(r1).to be_valid
      end

      it "rejects duplicate (persona, round=0)" do
        persona = create(:persona)
        create(:opinion, persona: persona, focus_group: persona.focus_group, round: 0)
        dup = build(:opinion, persona: persona, focus_group: persona.focus_group, round: 0)

        expect(dup).not_to be_valid
        expect(dup.errors[:persona_id]).to be_present
      end
    end
  end

  describe "scopes" do
    let(:fg) { create(:focus_group) }
    let(:persona) { create(:persona, focus_group: fg) }
    let!(:r0) { create(:opinion, persona: persona, focus_group: fg, round: 0) }
    let!(:r1) do
      persona2 = create(:persona, focus_group: fg)
      create(:opinion, :round_one, persona: persona2, focus_group: fg)
    end

    it ".round_zero returns only round=0 opinions" do
      expect(Opinion.round_zero).to contain_exactly(r0)
    end

    it ".round_one returns only round=1 opinions" do
      expect(Opinion.round_one).to contain_exactly(r1)
    end
  end

  describe "opinion versioning" do
    it "allows a persona to have round=0 and round=1 with different ratings" do
      persona = create(:persona)
      r0 = create(:opinion, persona: persona, focus_group: persona.focus_group, round: 0, rating: 5)
      r1 = create(:opinion, :round_one, persona: persona, focus_group: persona.focus_group, rating: 3)

      expect(persona.opinions.count).to eq(2)
      expect(r1.revised).to be true
      expect(r0.rating).to eq(5)
      expect(r1.rating).to eq(3)
    end
  end

  describe "status enum behavior" do
    it "allows status transition from pending to collected" do
      op = create(:opinion, status: "pending")
      op.collected!
      expect(op).to be_collected
    end
  end
end
