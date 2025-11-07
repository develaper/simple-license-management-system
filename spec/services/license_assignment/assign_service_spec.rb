# frozen_string_literal: true

require 'rails_helper'

RSpec.describe License::AssignService do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:product) { create(:product) }
  let(:subscription) { create(:subscription, account: account, product: product, number_of_licenses: 2) }

  let(:service) do
    described_class.new(
      account: account,
      users: [ user ],
      subscriptions: [ subscription ]
    )
  end

  describe '#call' do
    context 'with valid assignments' do
      it 'creates license assignments' do
        expect { service.call }
          .to change(::LicenseAssignment, :count).by(1)
      end

      it 'returns success result' do
        result = service.call

        expect(result).to have_attributes(
          success?: true,
          assignments_count: 1,
          error_messages: be_empty
        )
      end

      context 'with multiple users and subscriptions' do
        let(:second_user) { create(:user, account: account) }
        let(:second_product) { create(:product) }
        let(:second_subscription) { create(:subscription, account: account, product: second_product, number_of_licenses: 2) }

        let(:service) do
          described_class.new(
            account: account,
            users: [ user, second_user ],
            subscriptions: [ subscription, second_subscription ]
          )
        end

        it 'creates all license assignments' do
          expect { service.call }
            .to change(::LicenseAssignment, :count).by(4)
        end

        it 'returns correct assignments count' do
          result = service.call
          expect(result.assignments_count).to eq(4)
        end
      end
    end

    context 'with duplicate assignments' do
      before do
        create(:license_assignment, user: user, product: product, account: account)
      end

      it 'does not create new assignments' do
        expect { service.call }
          .not_to change(::LicenseAssignment, :count)
      end

      it 'returns failure result with error messages' do
        result = service.call

        expect(result).to have_attributes(
          success?: false,
          assignments_count: 0
        )
        expect(result.error_messages.first)
          .to include("already has a license")
      end
    end

    context 'when assignment fails to save' do
      before do
        allow_any_instance_of(::LicenseAssignment)
          .to receive(:save)
          .and_return(false)
      end

      it 'does not create any assignments' do
        expect { service.call }
          .not_to change(::LicenseAssignment, :count)
      end

      it 'returns failure result' do
        result = service.call

        expect(result).to have_attributes(
          success?: false,
          assignments_count: 0
        )
      end

      it 'rolls back the transaction' do
        service.call
        expect(::LicenseAssignment.count).to eq(0)
      end
    end
  end
end
