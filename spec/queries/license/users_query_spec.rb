# frozen_string_literal: true

require "rails_helper"

RSpec.describe License::UsersQuery do
  let(:account) { create(:account) }
  let(:user1) { create(:user, account: account) }
  let(:user2) { create(:user, account: account) }
  let(:user_from_other_account) { create(:user) }
  let(:user_ids) { [ user1.id, user2.id ] }
  let(:query) { described_class.new(account, user_ids) }

  describe "#call" do
    context "with valid user_ids" do
      before { user1 && user2 }

      it "returns the requested users" do
        result = query.call
        expect(result).to match_array([ user1, user2 ])
      end
    end

    context "with invalid user_ids" do
      let(:user_ids) { [ user1.id, user_from_other_account.id ] }
      before { user1 && user_from_other_account }

      it "raises ActiveRecord::RecordNotFound" do
        expect { query.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with non-existent user_ids" do
      let(:user_ids) { [ user1.id, "non-existent-id" ] }
      before { user1 }

      it "raises ActiveRecord::RecordNotFound" do
        expect { query.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with empty user_ids array" do
      let(:user_ids) { [] }

      it "returns an empty collection" do
        expect(query.call).to be_empty
      end
    end
  end
end
