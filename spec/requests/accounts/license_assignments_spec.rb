# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "/accounts/:account_id/license_assignments", type: :request do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:product) { create(:product) }
  let(:subscription) { create(:subscription, account: account, product: product) }
  let(:valid_attributes) do
    {
      subscription_ids: [ subscription.id ],
      user_ids: [ user.id ]
    }
  end

  # Para probar el caso de múltiples asignaciones
  let(:second_user) { create(:user, account: account) }
  let(:second_product) { create(:product) }
  let(:second_subscription) { create(:subscription, account: account, product: second_product) }
  let(:multiple_valid_attributes) do
    {
      subscription_ids: [ subscription.id, second_subscription.id ],
      user_ids: [ user.id, second_user.id ]
    }
  end

  shared_examples "successful page load" do
    it "returns a successful response" do
      get path
      expect(response).to be_successful
    end
  end

  shared_examples "renders unprocessable entity" do
    it "returns unprocessable entity status" do
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /new" do
    let(:path) { new_account_license_assignment_path(account) }

    it_behaves_like "successful page load"

    it "displays available subscriptions and users" do
      subscription && user # ensure they are created
      get path
      expect(response.body).to include(subscription.product.name)
      expect(response.body).to include(user.name)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new license assignment" do
        expect {
          post account_license_assignments_path(account), params: { license_assignment: valid_attributes }
        }.to change(LicenseAssignment, :count).by(1)
      end

      it "redirects to account page" do
        post account_license_assignments_path(account), params: { license_assignment: valid_attributes }
        expect(response).to redirect_to(account_path(account))
      end

      context "with multiple users and subscriptions" do
        it "creates multiple license assignments" do
          expect {
            post account_license_assignments_path(account),
                 params: { license_assignment: multiple_valid_attributes }
          }.to change(LicenseAssignment, :count).by(4) # 2 users * 2 products
        end
      end
    end

    context "with insufficient licenses" do
      before do
        # Crear una asignación que use todas las licencias disponibles
        create(:license_assignment, user: create(:user, account: account),
               product: product, account: account)
        subscription.update!(number_of_licenses: 1)
      end

      it "does not create new license assignments" do
        expect {
          post account_license_assignments_path(account), params: { license_assignment: valid_attributes }
        }.not_to change(LicenseAssignment, :count)
      end

      it "redirects with error message" do
        post account_license_assignments_path(account), params: { license_assignment: valid_attributes }
        expect(response).to redirect_to(account_path(account))
        expect(flash[:alert]).to include("not found")
      end
    end

    context "with duplicate assignments" do
      before do
        create(:license_assignment, user: user, product: product, account: account)
      end

      it "does not create new license assignments" do
        expect {
          post account_license_assignments_path(account), params: { license_assignment: valid_attributes }
        }.not_to change(LicenseAssignment, :count)
      end

      it "renders new with error" do
        post account_license_assignments_path(account), params: { license_assignment: valid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("already has a license")
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:license_assignment) { create(:license_assignment, user: user, product: product, account: account) }
    let(:destroy_attributes) do
      {
        user_ids: [ user.id ],
        product_id: product.id
      }
    end

    context "with valid parameters" do
      it "destroys the requested license assignments" do
        expect {
          delete account_license_assignment_path(account, 0),
                params: { license_assignment: destroy_attributes }
        }.to change(LicenseAssignment, :count).by(-1)
      end

      it "redirects to account page on success" do
        delete account_license_assignment_path(account, 0),
               params: { license_assignment: destroy_attributes }
        expect(response).to redirect_to(account_path(account))
      end
    end

    context "with non-existent assignments" do
      let(:invalid_destroy_attributes) do
        {
          user_ids: [ user.id ],
          product_id: create(:product).id # different product
        }
      end

      it "redirects with error message" do
        delete account_license_assignment_path(account, 0),
               params: { license_assignment: invalid_destroy_attributes }
        expect(response).to redirect_to(account_path(account))
        expect(flash[:alert]).to include("not found")
      end
    end

    context "with multiple assignments" do
      let(:second_assignment) { create(:license_assignment, user: second_user, product: product, account: account) }
      let(:multiple_destroy_attributes) do
        {
          user_ids: [ user.id, second_user.id ],
          product_id: product.id
        }
      end

      it "destroys all requested assignments" do
        second_assignment # ensure it's created
        expect {
          delete account_license_assignment_path(account, 0),
                params: { license_assignment: multiple_destroy_attributes }
        }.to change(LicenseAssignment, :count).by(-2)
      end
    end
  end
end
