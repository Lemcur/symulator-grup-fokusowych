require "rails_helper"

RSpec.describe Product, type: :model do
  describe "validations" do
    it "requires name" do
      product = build(:product, name: nil)
      expect(product).not_to be_valid
      expect(product.errors[:name]).to be_present
    end

    it "requires description" do
      product = build(:product, description: nil)
      expect(product).not_to be_valid
      expect(product.errors[:description]).to be_present
    end
  end

  describe "cascading delete" do
    it "destroys focus_groups on product destroy" do
      product = create(:product)
      create(:focus_group, product: product, user: product.user)

      expect { product.destroy }.to change(FocusGroup, :count).by(-1)
    end
  end
end
