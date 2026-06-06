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

  describe "image attachments" do
    let(:product) { create(:product) }
    let(:png_path) { Rails.root.join("docs/multiple-round/class-diagram.png") }

    def attach_png(times: 1)
      times.times do |i|
        product.images.attach(
          io: File.open(png_path),
          filename: "img-#{i}.png",
          content_type: "image/png"
        )
      end
    end

    it "accepts up to MAX_IMAGES images" do
      attach_png(times: Product::MAX_IMAGES)
      expect(product).to be_valid
    end

    it "rejects more than MAX_IMAGES images" do
      attach_png(times: Product::MAX_IMAGES + 1)
      expect(product).not_to be_valid
      expect(product.errors[:images].join).to include("maksymalnie")
    end

    it "rejects disallowed content types" do
      product.images.attach(
        io: StringIO.new("not really a pdf"),
        filename: "doc.pdf",
        content_type: "application/pdf"
      )
      expect(product).not_to be_valid
      expect(product.errors[:images].join).to include("niedozwolony typ")
    end

    it "rejects files larger than MAX_IMAGE_SIZE" do
      product.images.attach(
        io: StringIO.new("x" * (Product::MAX_IMAGE_SIZE + 1)),
        filename: "huge.png",
        content_type: "image/png"
      )
      expect(product).not_to be_valid
      expect(product.errors[:images].join).to include("przekracza")
    end

    it "is valid with no images attached" do
      expect(product.images).not_to be_attached
      expect(product).to be_valid
    end
  end
end
