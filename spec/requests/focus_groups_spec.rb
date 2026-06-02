require "rails_helper"

RSpec.describe "FocusGroups", type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product, user: user, name: "Lang App") }

  context "when signed in" do
    before { sign_in!(user) }

  describe "GET /focus_groups" do
    it "lists only current user's sessions" do
      own = create(:focus_group, user: user, product: product, name: "Mine")
      other = create(:focus_group, name: "Theirs")

      get focus_groups_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Mine")
      expect(response.body).not_to include("Theirs")
    end
  end

  describe "GET /focus_groups/new" do
    it "renders form with current user's products" do
      product
      create(:product, name: "Someone else's product")

      get new_focus_group_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Lang App")
      expect(response.body).not_to include("Someone else's product")
    end
  end

  describe "GET /focus_groups/:id" do
    it "shows own session" do
      fg = create(:focus_group, user: user, product: product, name: "My Session")

      get focus_group_path(fg)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("My Session")
    end

    it "returns 404 for another user's session" do
      other_users_session = create(:focus_group)

      get focus_group_path(other_users_session)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /focus_groups" do
    let(:valid_params) do
      {
        focus_group: {
          name: "Pilot",
          product_id: product.id,
          sample_size: 4,
          generation_mode: "proportions",
          persona_generator: "llm_two_pass",
          target_demographics: { "wiek" => { "25-29" => 1.0 } }.to_json
        }
      }
    end

    it "creates a session owned by current_user and enqueues GeneratePersonasJob" do
      expect {
        post focus_groups_path, params: valid_params
      }.to change { user.focus_groups.count }.by(1)
        .and have_enqueued_job(GeneratePersonasJob).with(an_instance_of(Integer))

      expect(response).to redirect_to(FocusGroup.last)
      expect(FocusGroup.last.user).to eq(user)
      expect(FocusGroup.last.product).to eq(product)
    end

    it "returns 404 when product belongs to another user" do
      other_users_product = create(:product)
      params = valid_params.deep_merge(focus_group: { product_id: other_users_product.id })

      expect {
        post focus_groups_path, params: params
      }.not_to change(FocusGroup, :count)

      expect(response).to have_http_status(:not_found)
    end

    it "renders new with errors when invalid" do
      invalid = valid_params.deep_merge(focus_group: { name: "" })

      expect {
        post focus_groups_path, params: invalid
      }.not_to change(FocusGroup, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "does not enqueue job when invalid" do
      invalid = valid_params.deep_merge(focus_group: { name: "" })

      expect {
        post focus_groups_path, params: invalid
      }.not_to have_enqueued_job(GeneratePersonasJob)
    end
  end

  end

  context "when not signed in" do
    it "redirects index to sign in page" do
      get focus_groups_path

      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
