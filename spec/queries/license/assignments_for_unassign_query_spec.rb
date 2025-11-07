# frozen_string_literal: true

require "rails_helper"

RSpec.describe License::AssignmentsForUnassignQuery do
  let(:account) { create(:account) }
  let(:user1) { create(:user, account: account) }
  let(:user2) { create(:user, account: account) }
  let(:product) { create(:product) }
  let(:assignment1) { create(:license_assignment, account: account, user: user1, product: product) }
  let(:assignment2) { create(:license_assignment, account: account, user: user2, product: product) }
  let(:user_ids) { [ user1.id, user2.id ] }
  let(:query) { described_class.new(account, user_ids, product.id) }

  describe "#call" do
    context "with existing assignments" do
      before { assignment1 && assignment2 }

      it "returns the matching assignments" do
        result = query.call
        expect(result).to match_array([ assignment1, assignment2 ])
      end
    end

    context "when no assignments match" do
      let(:other_product) { create(:product) }
      let(:query) { described_class.new(account, user_ids, other_product.id) }

      it "raises ActiveRecord::RecordNotFound" do
        expect { query.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with assignments from another account" do
      let(:other_account) { create(:account) }
      let(:other_user) { create(:user, account: other_account) }
      let(:other_assignment) { create(:license_assignment, account: other_account, user: other_user, product: product) }
      let(:user_ids) { [ other_user.id ] }
      before { other_assignment }

      it "raises ActiveRecord::RecordNotFound" do
        expect { query.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with partial matches" do
      before { assignment1 }

      it "returns only the matching assignments" do
        result = query.call
        expect(result).to match_array([ assignment1 ])
      end
    end

    context "with empty user_ids array" do
      let(:user_ids) { [] }

      it "raises ActiveRecord::RecordNotFound" do
        expect { query.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
