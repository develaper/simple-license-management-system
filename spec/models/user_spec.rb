require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end
  end

  describe 'validations' do
    describe 'name' do
      context 'when name is not present' do
        it 'is not valid' do
          user = build(:user, name: nil)
          expect(user).not_to be_valid
          expect(user.errors[:name]).to include("can't be blank")
        end
      end

      context 'when name is present' do
        it 'is valid' do
          user = build(:user, name: 'Test User')
          expect(user).to be_valid
        end
      end
    end

    describe 'email' do
      context 'when email is not present' do
        it 'is not valid' do
          user = build(:user, email: nil)
          expect(user).not_to be_valid
          expect(user.errors[:email]).to include("can't be blank")
        end
      end

      context 'when email is not unique' do
        it 'is not valid' do
          existing_user = create(:user)
          user = build(:user, email: existing_user.email)
          expect(user).not_to be_valid
          expect(user.errors[:email]).to include("has already been taken")
        end
      end

      context 'when email format is invalid' do
        it 'is not valid' do
          user = build(:user, email: 'invalid_email')
          expect(user).not_to be_valid
          expect(user.errors[:email]).to include("is invalid")
        end
      end

      context 'when email is valid' do
        it 'is valid' do
          user = build(:user, email: 'test@example.com')
          expect(user).to be_valid
        end
      end
    end

    describe 'account' do
      context 'when account is not present' do
        it 'is not valid' do
          user = build(:user, account: nil)
          expect(user).not_to be_valid
          expect(user.errors[:account]).to include("must exist")
        end
      end

      context 'when account is present' do
        it 'is valid' do
          account = create(:account)
          user = build(:user, account: account)
          expect(user).to be_valid
        end
      end
    end
  end

  describe 'database constraints' do
    context 'when name is null' do
      it 'raises an error' do
        user = build(:user, name: nil)
        expect { user.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
      end
    end

    context 'when email is null' do
      it 'raises an error' do
        user = build(:user, email: nil)
        expect { user.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
      end
    end

    context 'when email is not unique' do
      it 'raises an error' do
        existing_user = create(:user)
        user = build(:user, email: existing_user.email)
        expect { user.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    context 'when account_id is null' do
      it 'raises an error' do
        user = build(:user, account: nil)
        expect { user.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
      end
    end
  end
end
