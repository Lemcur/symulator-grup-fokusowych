require "rails_helper"

RSpec.describe User, type: :model do
  describe "Devise" do
    it "wymaga email i hasła" do
      user = User.new
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
      expect(user.errors[:password]).to be_present
    end

    it "zapisuje encrypted_password zamiast plaintext" do
      user = create(:user, password: "tajne_haslo")
      expect(user.encrypted_password).to be_present
      expect(user.encrypted_password).not_to eq("tajne_haslo")
    end

    it "waliduje unikalność emaila" do
      create(:user, email: "duplikat@example.com")
      user2 = build(:user, email: "duplikat@example.com")
      expect(user2).not_to be_valid
    end
  end

  describe "kaskadowe usuwanie" do
    it "usuwa produkty i sesje przy destroy" do
      user = create(:user)
      create(:product, user: user)
      create(:focus_group, user: user)

      expect { user.destroy }.to change(Product, :count).by(-1)
        .and change(FocusGroup, :count).by(-1)
    end
  end
end
