require "rails_helper"

RSpec.describe FocusGroup, type: :model do
  describe "validations" do
    it "requires name" do
      fg = build(:focus_group, name: nil)
      expect(fg).not_to be_valid
      expect(fg.errors[:name]).to be_present
    end

    it "requires sample_size > 0" do
      expect(build(:focus_group, sample_size: 0)).not_to be_valid
      expect(build(:focus_group, sample_size: -1)).not_to be_valid
      expect(build(:focus_group, sample_size: 1)).to be_valid
    end

    describe "target_demographics_matches_mode" do
      it "accepts a hash for proportions mode" do
        fg = build(:focus_group, generation_mode: "proportions",
                                  target_demographics: { "gender" => { "k" => 0.5, "m" => 0.5 } })
        expect(fg).to be_valid
      end

      it "rejects an array for proportions mode" do
        fg = build(:focus_group, generation_mode: "proportions", target_demographics: [])
        expect(fg).not_to be_valid
        expect(fg.errors[:target_demographics]).to include(/musi być hashem/)
      end

      it "requires sum(count) == sample_size for slots mode" do
        fg = build(:focus_group, :with_slots, sample_size: 4)
        expect(fg).to be_valid

        fg.sample_size = 5
        expect(fg).not_to be_valid
        expect(fg.errors[:target_demographics]).to include(/suma count.*sample_size/)
      end

      it "rejects a hash for slots mode" do
        fg = build(:focus_group, generation_mode: "slots",
                                  target_demographics: { "key" => "value" })
        expect(fg).not_to be_valid
        expect(fg.errors[:target_demographics]).to include(/musi być tablicą/)
      end
    end
  end

  describe "status enum behavior" do
    it "supports the full status lifecycle" do
      fg = create(:focus_group)
      expect(fg).to be_pending

      fg.generating_personas!
      expect(fg).to be_generating_personas

      fg.deliberating!
      fg.synthesizing!
      fg.completed!
      expect(fg).to be_completed
    end
  end

  describe "#expand_slots" do
    context "proportions mode" do
      it "returns sample_size slots with dimensions from target_demographics" do
        fg = create(:focus_group, sample_size: 10)
        slots = fg.expand_slots

        expect(slots.size).to eq(10)
        slots.each do |slot|
          expect(slot.keys).to contain_exactly("gender", "age")
          expect(slot["gender"]).to be_in(%w[kobieta mezczyzna])
          expect(slot["age"]).to be_in(%w[25-34 35-44])
        end
      end

      it "distribution is close to proportions for large N" do
        fg = create(:focus_group, sample_size: 1000,
                                   target_demographics: { "gender" => { "kobieta" => 0.7, "mezczyzna" => 0.3 } })
        slots = fg.expand_slots
        women = slots.count { |s| s["gender"] == "kobieta" }

        expect(women).to be_between(600, 800)
      end
    end

    context "slots mode" do
      it "expands slots with count field" do
        fg = create(:focus_group, :with_slots, sample_size: 4)
        slots = fg.expand_slots

        expect(slots.size).to eq(4)
        expect(slots.count { |s| s["gender"] == "kobieta" }).to eq(2)
        expect(slots.count { |s| s["gender"] == "mezczyzna" }).to eq(2)
        slots.each { |s| expect(s).not_to have_key("count") }
      end
    end
  end

  describe "#progress" do
    let(:fg) { create(:focus_group, sample_size: 4) }

    it "returns 0 for pending" do
      expect(fg.progress).to eq(0.0)
    end

    it "returns persona ratio for generating_personas" do
      fg.update!(status: "generating_personas")
      create_list(:persona, 2, focus_group: fg)
      expect(fg.progress).to eq(0.5)
    end

    it "returns round=0 opinion ratio for collecting_opinions" do
      fg.update!(status: "collecting_opinions")
      personas = create_list(:persona, 4, focus_group: fg)
      personas.first(3).each { |p| create(:opinion, persona: p, focus_group: fg, round: 0) }
      expect(fg.progress).to eq(0.75)
    end

    it "returns round=1 opinion ratio for deliberating" do
      fg.update!(status: "deliberating")
      personas = create_list(:persona, 4, focus_group: fg)
      personas.each { |p| create(:opinion, persona: p, focus_group: fg, round: 0) }
      personas.first(2).each { |p| create(:opinion, :round_one, persona: p, focus_group: fg) }
      expect(fg.progress).to eq(0.5)
    end

    it "returns 1.0 for completed" do
      fg.update!(status: "completed")
      expect(fg.progress).to eq(1.0)
    end
  end

  describe "#all_agents_done? / #all_deliberations_done?" do
    let(:fg) { create(:focus_group, sample_size: 3) }
    let!(:personas) { create_list(:persona, 3, focus_group: fg) }

    it "all_agents_done? is true when all round=0 opinions collected" do
      expect(fg.all_agents_done?).to be false
      personas.each { |p| create(:opinion, persona: p, focus_group: fg, round: 0) }
      expect(fg.all_agents_done?).to be true
    end

    it "all_deliberations_done? is true when all round=1 opinions collected" do
      personas.each { |p| create(:opinion, persona: p, focus_group: fg, round: 0) }
      expect(fg.all_deliberations_done?).to be false
      personas.each { |p| create(:opinion, :round_one, persona: p, focus_group: fg) }
      expect(fg.all_deliberations_done?).to be true
    end
  end

  describe "cascading delete" do
    it "destroys personas, opinions, chairman and recommendation on destroy" do
      fg = create(:focus_group)
      personas = create_list(:persona, 2, focus_group: fg)
      personas.each { |p| create(:opinion, persona: p, focus_group: fg, round: 0) }
      create(:chairman, focus_group: fg)
      create(:recommendation, focus_group: fg)

      expect { fg.destroy }
        .to change(Persona, :count).by(-2)
        .and change(Opinion, :count).by(-2)
        .and change(Chairman, :count).by(-1)
        .and change(Recommendation, :count).by(-1)
    end
  end
end
