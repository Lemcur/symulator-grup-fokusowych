require "rails_helper"

RSpec.describe Product, type: :model do
  describe "walidacje" do
    it "wymaga name" do
      product = build(:product, name: nil)
      expect(product).not_to be_valid
      expect(product.errors[:name]).to be_present
    end

    it "wymaga description" do
      product = build(:product, description: nil)
      expect(product).not_to be_valid
      expect(product.errors[:description]).to be_present
    end
  end

  describe "kaskadowe usuwanie" do
    it "usuwa sesje przy destroy produktu" do
      product = create(:product)
      create(:focus_group, product: product, user: product.user)

      expect { product.destroy }.to change(FocusGroup, :count).by(-1)
    end
  end
end
