require "rails_helper"

RSpec.describe Persona, type: :model do
  describe "walidacje" do
    it "wymaga name" do
      persona = build(:persona, name: nil)
      expect(persona).not_to be_valid
      expect(persona.errors[:name]).to be_present
    end

    it "wymaga description" do
      persona = build(:persona, description: nil)
      expect(persona).not_to be_valid
      expect(persona.errors[:description]).to be_present
    end
  end

  describe "helpery opinii" do
    let(:persona) { create(:persona) }

    it "round_zero_opinion zwraca opinię z round=0" do
      r0 = create(:opinion, persona: persona, focus_group: persona.focus_group, round: 0)
      create(:opinion, :round_one, persona: persona, focus_group: persona.focus_group)

      expect(persona.round_zero_opinion).to eq(r0)
    end

    it "round_one_opinion zwraca opinię z round=1" do
      create(:opinion, persona: persona, focus_group: persona.focus_group, round: 0)
      r1 = create(:opinion, :round_one, persona: persona, focus_group: persona.focus_group)

      expect(persona.round_one_opinion).to eq(r1)
    end

    it "zwraca nil jeśli brak opinii w danej rundzie" do
      expect(persona.round_zero_opinion).to be_nil
      expect(persona.round_one_opinion).to be_nil
    end
  end

  describe "kaskadowe usuwanie" do
    it "usuwa opinie przy destroy persony" do
      persona = create(:persona)
      create(:opinion, persona: persona, focus_group: persona.focus_group)
      create(:opinion, :round_one, persona: persona, focus_group: persona.focus_group)

      expect { persona.destroy }.to change(Opinion, :count).by(-2)
    end
  end
end
