require 'rails_helper'

RSpec.describe "/accounts", type: :request do
  let(:valid_attributes) { { name: "Test Account" } }
  let(:invalid_attributes) { { name: "" } }
  let(:new_attributes) { { name: "Updated Account" } }

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
      expect(flash[:notice]).to eq("Account was successfully #{action}.")
    end
  end

  shared_examples "renders unprocessable entity" do
    it "returns unprocessable entity status" do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("error")
    end
  end

  describe "GET /index" do
    let(:path) { accounts_url }

    it_behaves_like "successful page load"

    context "with existing accounts" do
      let!(:account) { Account.create!(valid_attributes) }

      it "displays the account" do
        get path
        expect(response.body).to include(account.name)
      end
    end
  end

  describe "GET /show" do
    let!(:account) { Account.create!(valid_attributes) }
    let(:path) { account_url(account) }

    it_behaves_like "successful page load"

    it "displays the account details" do
      get path
      expect(response.body).to include(account.name)
    end

    context "when account does not exist" do
      it "redirects to index with alert" do
        get account_url("nonexistent")
        expect(response).to redirect_to(accounts_path)
        expect(flash[:alert]).to eq("Account not found.")
      end
    end
  end

  describe "GET /new" do
    let(:path) { new_account_url }
    it_behaves_like "successful page load"
  end

  describe "GET /edit" do
    let!(:account) { Account.create!(valid_attributes) }
    let(:path) { edit_account_url(account) }
    it_behaves_like "successful page load"
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:redirect_path) { account_url(Account.last) }

      it "creates a new Account" do
        expect { post accounts_url, params: { account: valid_attributes } }
          .to change(Account, :count).by(1)
      end

      context "after creation" do
        before do
          post accounts_url, params: { account: valid_attributes }
        end

        it_behaves_like "successful redirect with notice", "created"
      end
    end

    context "with invalid parameters" do
      before do
        post accounts_url, params: { account: invalid_attributes }
      end

      it "does not create a new Account" do
        expect { post accounts_url, params: { account: invalid_attributes } }
          .not_to change(Account, :count)
      end

      it_behaves_like "renders unprocessable entity"
    end
  end

  describe "PATCH /update" do
    let!(:account) { Account.create!(valid_attributes) }

    context "with valid parameters" do
      let(:redirect_path) { account_url(account) }

      before do
        patch account_url(account), params: { account: new_attributes }
      end

      it "updates the requested account" do
        account.reload
        expect(account.name).to eq(new_attributes[:name])
      end

      it_behaves_like "successful redirect with notice", "updated"
    end

    context "with invalid parameters" do
      before do
        patch account_url(account), params: { account: invalid_attributes }
      end

      it_behaves_like "renders unprocessable entity"
    end
  end

  describe "DELETE /destroy" do
    let!(:account) { Account.create!(valid_attributes) }
    let(:redirect_path) { accounts_url }

    it "destroys the requested account" do
      expect { delete account_url(account) }.to change(Account, :count).by(-1)
    end

    context "after deletion" do
      before do
        delete account_url(account)
      end

      it_behaves_like "successful redirect with notice", "deleted"
    end
  end
end
