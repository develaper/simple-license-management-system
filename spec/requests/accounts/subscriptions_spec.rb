# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "/accounts/:account_id/subscriptions", type: :request do
  let(:account) { create(:account) }
  let(:valid_attributes) { attributes_for(:subscription).merge(product_id: create(:product).id) }
  let(:invalid_attributes) { { number_of_licenses: 0 } }
  let(:new_attributes) { { number_of_licenses: 50 } }

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
      expect(flash[:notice]).to eq(I18n.t("accounts.subscriptions.#{action}"))
    end
  end

  shared_examples "renders unprocessable entity" do
    it "returns unprocessable entity status" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("error")
    end
  end

  describe "GET /index" do
    let(:path) { account_subscriptions_path(account) }

    it_behaves_like "successful page load"

    context "with existing subscriptions" do
      let!(:subscription) { create(:subscription, account: account) }

      it "displays the subscription" do
        get path
        expect(response).to be_successful
      end
    end
  end

  describe "GET /show" do
    let!(:subscription) { create(:subscription, account: account) }
    let(:path) { account_subscription_path(account, subscription) }

    it_behaves_like "successful page load"

    it "displays the subscription details" do
      get path
      expect(response).to be_successful
    end

    context "when subscription does not exist" do
      it "redirects to index with alert" do
        get account_subscription_path(account, "nonexistent")
        expect(response).to redirect_to(account_subscriptions_path(account))
        expect(flash[:alert]).to eq(I18n.t("accounts.subscriptions.not_found", resource: "Subscription"))
      end
    end
  end

  describe "GET /new" do
    let(:path) { new_account_subscription_path(account) }

    it_behaves_like "successful page load"

    it "displays the new subscription form" do
      get path
      expect(response.body).to include("New Subscription")
    end
  end

  describe "POST /create" do
    let(:path) { account_subscriptions_path(account) }
    let(:redirect_path) { account_subscriptions_path(account) }

    context "with valid parameters" do
      it "creates a new Subscription" do
        expect {
          post path, params: { subscription: valid_attributes }
        }.to change(Subscription, :count).by(1)
      end

      it "creates a subscription associated with the account" do
        post path, params: { subscription: valid_attributes }
        expect(Subscription.last.account).to eq(account)
      end

      context "after creation" do
        before { post path, params: { subscription: valid_attributes } }
        it_behaves_like "successful redirect with notice", "created"
      end
    end

    context "with invalid parameters" do
      before { post path, params: { subscription: invalid_attributes } }
      it_behaves_like "renders unprocessable entity"
    end
  end
end
