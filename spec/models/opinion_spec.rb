require "rails_helper"

RSpec.describe Opinion, type: :model do
  describe "walidacje" do
    it "round musi być 0 lub 1" do
      [0, 1].each do |r|
        expect(build(:opinion, round: r)).to be_valid
      end
      [-1, 2, nil].each do |r|
        expect(build(:opinion, round: r)).not_to be_valid
      end
    end

    describe "uniqueness [persona, round]" do
      it "pozwala na jedną opinię round=0 i jedną round=1 dla tej samej persony" do
        persona = create(:persona)
        create(:opinion, persona: persona, focus_group: persona.focus_group, round: 0)
        r1 = build(:opinion, :round_one, persona: persona, focus_group: persona.focus_group)
        expect(r1).to be_valid
      end

      it "blokuje duplikat (persona, round=0)" do
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

    it ".round_zero zwraca tylko round=0" do
      expect(Opinion.round_zero).to contain_exactly(r0)
    end

    it ".round_one zwraca tylko round=1" do
      expect(Opinion.round_one).to contain_exactly(r1)
    end
  end

  describe "wersjonowanie opinii" do
    it "persona może mieć round=0 i round=1 z różnym ratingiem" do
      persona = create(:persona)
      r0 = create(:opinion, persona: persona, focus_group: persona.focus_group, round: 0, rating: 5)
      r1 = create(:opinion, :round_one, persona: persona, focus_group: persona.focus_group, rating: 3)

      expect(persona.opinions.count).to eq(2)
      expect(r1.revised).to be true
      expect(r0.rating).to eq(5)
      expect(r1.rating).to eq(3)
    end
  end

  describe "enum status (behavior)" do
    it "pozwala na zmianę statusu pending -> collected" do
      op = create(:opinion, status: "pending")
      op.collected!
      expect(op).to be_collected
    end
  end
end
