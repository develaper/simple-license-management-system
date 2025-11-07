# frozen_string_literal: true

require "rails_helper"

RSpec.describe License::SubscriptionsQuery do
  let(:account) { create(:account) }
  let(:product1) { create(:product) }
  let(:product2) { create(:product) }
  let(:subscription1) { create(:subscription, account: account, product: product1, number_of_licenses: 5) }
  let(:subscription2) { create(:subscription, account: account, product: product2, number_of_licenses: 3) }
  let(:subscription_ids) { [ subscription1.id, subscription2.id ] }
  let(:needed_licenses) { 2 }
  let(:query) { described_class.new(account, subscription_ids, needed_licenses) }

  describe "#call" do
    context "with valid subscription_ids and sufficient licenses" do
      before { subscription1 && subscription2 }

      it "returns the requested subscriptions" do
        result = query.call
        expect(result).to match_array([ subscription1, subscription2 ])
      end
    end

    context "with insufficient licenses" do
      let(:needed_licenses) { 6 }
      before { subscription1 && subscription2 }

      it "raises ActiveRecord::RecordNotFound with insufficient licenses message" do
        expect { query.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with non-existent subscription_ids" do
      let(:subscription_ids) { [ "non-existent-id" ] }

      it "raises ActiveRecord::RecordNotFound" do
        expect { query.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with subscriptions from another account" do
      let(:other_account) { create(:account) }
      let(:other_subscription) { create(:subscription, account: other_account) }
      let(:subscription_ids) { [ other_subscription.id ] }
      before { other_subscription }

      it "raises ActiveRecord::RecordNotFound" do
        expect { query.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with partially used licenses" do
      before do
        subscription1
        3.times do
          user = create(:user, account: account)
          create(:license_assignment, account: account, product: product1, user: user)
        end
      end

      let(:needed_licenses) { 3 }

      it "raises ActiveRecord::RecordNotFound" do
        expect { query.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with empty subscription_ids array" do
      let(:subscription_ids) { [] }

      it "raises ActiveRecord::RecordNotFound" do
        expect { query.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
