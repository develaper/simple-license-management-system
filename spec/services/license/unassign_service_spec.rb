# frozen_string_literal: true

require 'rails_helper'

  RSpec.describe License::UnassignService do
  include_context "with license assignment setup"

  let(:license_assignment) do
    create(:license_assignment, user: user, product: product, account: account)
  end
  let(:service) { described_class.new([ license_assignment ]) }

  subject { service }

  describe '#call' do
    context 'with existing assignments' do
      before { license_assignment }

      it { expect { subject.call }.to change(::LicenseAssignment, :count).by(-1) }
      it_behaves_like "a license service result"

      context 'with multiple assignments' do
        let(:second_user) { create(:user, account: account) }
        let(:second_assignment) do
          create(:license_assignment, user: second_user, product: product, account: account)
        end
        let(:service) { described_class.new([ license_assignment, second_assignment ]) }

        before { second_assignment }

        it { expect { subject.call }.to change(::LicenseAssignment, :count).by(-2) }
        it_behaves_like "a license service result", count: 2
      end
    end

    context 'with no assignments' do
      let(:service) { described_class.new([]) }

      it_behaves_like "a license service result", success: false, count: 0

      it "includes appropriate error message" do
        expect(subject.call.error_messages.first).to include("No matching license assignments found")
      end
    end

    context 'when assignment fails to destroy' do
      before { allow(license_assignment).to receive(:destroy).and_return(false) }

      it_behaves_like "a transaction rollback"
      it_behaves_like "a license service result", success: false, count: 0
    end
  end
end
