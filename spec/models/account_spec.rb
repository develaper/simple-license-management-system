require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:account)).to be_valid
    end
  end

  describe 'validations' do
    describe 'name' do
      context 'when name is not present' do
        it 'is not valid' do
          account = build(:account, name: nil)
          expect(account).not_to be_valid
          expect(account.errors[:name]).to include("can't be blank")
        end
      end

      context 'when name is present' do
        it 'is valid' do
          account = build(:account, name: 'Test Account')
          expect(account).to be_valid
        end
      end
    end
  end

  describe 'database constraints' do
    context 'when name is null' do
      it 'raises an error' do
        account = build(:account, name: nil)
        expect { account.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
      end
    end
  end
end
