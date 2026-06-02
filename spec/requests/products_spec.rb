require "rails_helper"

RSpec.describe "Products", type: :request do
  let(:user) { create(:user) }

  context "when signed in" do
    before { sign_in!(user) }

  describe "GET /products" do
    it "lists only current user's products" do
      own = create(:product, user: user, name: "Mine")
      other = create(:product, name: "Theirs")

      get products_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Mine")
      expect(response.body).not_to include("Theirs")
    end
  end

  describe "GET /products/:id" do
    it "shows own product" do
      product = create(:product, user: user, name: "Lang App")

      get product_path(product)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Lang App")
    end

    it "returns 404 for another user's product" do
      other_users_product = create(:product)

      get product_path(other_users_product)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /products" do
    it "creates a product owned by current_user" do
      expect {
        post products_path, params: { product: { name: "New", description: "Desc" } }
      }.to change { user.products.count }.by(1)

      expect(response).to redirect_to(Product.last)
    end

    it "renders new with errors when invalid" do
      post products_path, params: { product: { name: "", description: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /products/:id" do
    it "updates own product" do
      product = create(:product, user: user, name: "Old")

      patch product_path(product), params: { product: { name: "New", description: product.description } }

      expect(product.reload.name).to eq("New")
    end

    it "returns 404 when updating another user's product" do
      other_users_product = create(:product)

      patch product_path(other_users_product), params: { product: { name: "Hijacked", description: "x" } }

      expect(response).to have_http_status(:not_found)
      expect(other_users_product.reload.name).not_to eq("Hijacked")
    end
  end

  describe "DELETE /products/:id" do
    it "destroys own product" do
      product = create(:product, user: user)

      expect {
        delete product_path(product)
      }.to change(Product, :count).by(-1)
    end

    it "returns 404 for another user's product without deleting it" do
      other_users_product = create(:product)

      expect {
        delete product_path(other_users_product)
      }.not_to change(Product, :count)

      expect(response).to have_http_status(:not_found)
    end
  end

  end

  context "when not signed in" do
    it "redirects index to sign in page" do
      get products_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
