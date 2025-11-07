require 'rails_helper'

RSpec.describe "/accounts/:account_id/users", type: :request do
  let(:account) { create(:account) }
  let(:valid_attributes) { attributes_for(:user) }
  let(:invalid_attributes) { { name: "", email: "" } }
  let(:new_attributes) { { name: "Updated User", email: "updated@example.com" } }

  shared_examples "successful page load" do
    it "returns a successful response" do
      get path
      expect(response).to be_successful
    end
  end

  shared_examples "successful redirect with notice" do |action|
    it "redirects with success message" do
      expect(response).to redirect_to(redirect_path)
      follow_redirect!
      expect(flash[:notice]).to eq(I18n.t("accounts.users.#{action}"))
    end
  end

  shared_examples "renders unprocessable entity" do
    it "returns unprocessable entity status" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("error")
    end
  end

  describe "GET /accounts/:account_id/users/new" do
    let(:path) { new_account_user_path(account) }

    it_behaves_like "successful page load"

    it "displays the new user form" do
      get path
      expect(response.body).to include("New User")
    end
  end

  describe "GET /accounts/:account_id/users/:id/edit" do
    let(:user) { create(:user, account: account) }
    let(:path) { edit_account_user_path(account, user) }

    it_behaves_like "successful page load"

    it "displays the edit user form" do
      get path
      expect(response.body).to include("Edit User")
    end

    context "when user doesn't exist" do
      it "redirects to root with alert" do
        get edit_account_user_path(account, "non-existent-id")
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("User not found")
      end
    end
  end

  describe "POST /accounts/:account_id/users" do
    let(:path) { account_users_path(account) }
    let(:redirect_path) { account_path(account) }

    context "with valid parameters" do
      it "creates a new User" do
        expect {
          post path, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
      end

      it "creates a user associated with the account" do
        post path, params: { user: valid_attributes }
        expect(User.last.account).to eq(account)
      end

      context "after creation" do
        before { post path, params: { user: valid_attributes } }
        it_behaves_like "successful redirect with notice", "created"
      end
    end

    context "with invalid parameters" do
      before { post path, params: { user: invalid_attributes } }
      it_behaves_like "renders unprocessable entity"
    end

    context "with duplicate email" do
      let!(:existing_user) { create(:user) }
      let(:duplicate_attributes) { valid_attributes.merge(email: existing_user.email) }

      it "does not create a new user" do
        expect {
          post path, params: { user: duplicate_attributes }
        }.not_to change(User, :count)
      end

      it "returns unprocessable entity status" do
        post path, params: { user: duplicate_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("has already been taken")
      end
    end
  end

  describe "PATCH /accounts/:account_id/users/:id" do
    let!(:user) { create(:user, account: account) }
    let(:path) { account_user_path(account, user) }
    let(:redirect_path) { account_path(account) }

    context "with valid parameters" do
      before { patch path, params: { user: new_attributes } }

      it "updates the user" do
        user.reload
        expect(user.name).to eq("Updated User")
        expect(user.email).to eq("updated@example.com")
      end

      it_behaves_like "successful redirect with notice", "updated"
    end

    context "with invalid parameters" do
      before { patch path, params: { user: invalid_attributes } }
      it_behaves_like "renders unprocessable entity"
    end

    context "with duplicate email" do
      let!(:existing_user) { create(:user) }

      it "does not update the user" do
        patch path, params: { user: { email: existing_user.email } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("has already been taken")
      end
    end
  end

  describe "DELETE /accounts/:account_id/users/:id" do
    let!(:user) { create(:user, account: account) }
    let(:path) { account_user_path(account, user) }
    let(:redirect_path) { account_path(account) }

    it "destroys the requested user" do
      expect {
        delete path
      }.to change(User, :count).by(-1)
    end

    context "after deletion" do
      before { delete path }
      it_behaves_like "successful redirect with notice", "deleted"
    end
  end
end
