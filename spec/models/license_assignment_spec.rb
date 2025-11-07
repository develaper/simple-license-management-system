require 'rails_helper'

RSpec.describe LicenseAssignment, type: :model do
  describe 'factory' do
    let(:account) { create(:account) }
    let(:user) { create(:user, account: account) }
    it 'has a valid factory' do
      license_assignment = build(:license_assignment, account: account, user: user)
      expect(license_assignment).to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:account) }
    it { should belong_to(:user) }
    it { should belong_to(:product) }
  end

  describe 'validations' do
    let(:account) { create(:account) }
    let(:other_account) { create(:account) }
    let(:user) { create(:user, account: account) }
    let(:product) { create(:product) }

    it 'is valid when user belongs to the account' do
      license_assignment = build(:license_assignment, account: account, user: user, product: product)
      expect(license_assignment).to be_valid
    end

    it 'is invalid when user belongs to a different account' do
      user_from_other_account = create(:user, account: other_account)
      license_assignment = build(:license_assignment, account: account, user: user_from_other_account, product: product)
      expect(license_assignment).to be_invalid
      expect(license_assignment.errors[:user]).to include("must belong to the same account")
    end
  end
end
