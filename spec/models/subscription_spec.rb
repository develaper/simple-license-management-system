# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'factory' do
    let(:account) { create(:account) }
    let(:product) { create(:product) }
    it 'has a valid factory' do
      expect(build(:subscription, account: account, product: product)).to be_valid
    end
  end

  describe 'validations' do
    let(:account) { create(:account) }
    let(:product) { create(:product) }

    describe 'account_id' do
      context 'when account_id is not present' do
        it 'is not valid' do
          subscription = build(:subscription, :without_account)
          expect(subscription).not_to be_valid
          expect(subscription.errors[:account]).to include("must exist")
        end
      end

      context 'when account_id is present' do
        it 'is valid' do
          subscription = build(:subscription, account: account, product: product)
          expect(subscription).to be_valid
        end
      end
    end

    describe 'product_id' do
      context 'when product_id is not present' do
        it 'is not valid' do
          subscription = build(:subscription, :without_product)
          expect(subscription).not_to be_valid
          expect(subscription.errors[:product]).to include("must exist")
        end
      end

      context 'when product_id is present' do
        it 'is valid' do
          subscription = build(:subscription, account: account, product: product)
          expect(subscription).to be_valid
        end
      end

      context 'when product is already subscribed for the account' do
        it 'is not valid' do
          existing_subscription = create(:subscription)
          new_subscription = build(:subscription, account: existing_subscription.account, product: existing_subscription.product)
          expect(new_subscription).not_to be_valid
          expect(new_subscription.errors[:product_id]).to include("already has an active subscription for this account")
        end
      end
    end

    describe 'number_of_licenses' do
      context 'when number_of_licenses is not present' do
        it 'is not valid' do
          subscription = build(:subscription, account: account, product: product, number_of_licenses: nil)
          expect(subscription).not_to be_valid
          expect(subscription.errors[:number_of_licenses]).to include("can't be blank")
        end
      end

      context 'when number_of_licenses is zero' do
        it 'is not valid' do
          subscription = build(:subscription, account: account, product: product, number_of_licenses: 0)
          expect(subscription).not_to be_valid
          expect(subscription.errors[:number_of_licenses]).to include("must be greater than 0")
        end
      end

      context 'when number_of_licenses is negative' do
        it 'is not valid' do
          subscription = build(:subscription, account: account, product: product, number_of_licenses: -1)
          expect(subscription).not_to be_valid
          expect(subscription.errors[:number_of_licenses]).to include("must be greater than 0")
        end
      end

      context 'when number_of_licenses is positive' do
        it 'is valid' do
          subscription = build(:subscription, account: account, product: product, number_of_licenses: 1)
          expect(subscription).to be_valid
        end
      end
    end

    describe 'issued_at' do
      context 'when issued_at is not present' do
        it 'is not valid' do
          subscription = build(:subscription, account: account, product: product, issued_at: nil)
          expect(subscription).not_to be_valid
          expect(subscription.errors[:issued_at]).to include("can't be blank")
        end
      end

      context 'when issued_at is present' do
        it 'is valid' do
          subscription = build(:subscription, account: account, product: product, issued_at: Time.current)
          expect(subscription).to be_valid
        end
      end
    end

    describe 'expires_at' do
      context 'when expires_at is not present' do
        it 'is not valid' do
          subscription = build(:subscription, account: account, product: product, expires_at: nil)
          expect(subscription).not_to be_valid
          expect(subscription.errors[:expires_at]).to include("can't be blank")
        end
      end

      context 'when expires_at is before issued_at' do
        it 'is not valid' do
          subscription = build(:subscription, account: account, product: product,
                             issued_at: Time.current, expires_at: 1.day.ago)
          expect(subscription).not_to be_valid
          expect(subscription.errors[:expires_at]).to include("must be after the issued date")
        end
      end

      context 'when expires_at is equal to issued_at' do
        it 'is not valid' do
          time = Time.current
          subscription = build(:subscription, account: account, product: product,
                             issued_at: time, expires_at: time)
          expect(subscription).not_to be_valid
          expect(subscription.errors[:expires_at]).to include("must be after the issued date")
        end
      end

      context 'when expires_at is after issued_at' do
        it 'is valid' do
          subscription = build(:subscription, account: account, product: product,
                             issued_at: Time.current, expires_at: 1.day.from_now)
          expect(subscription).to be_valid
        end
      end
    end
  end

  describe 'database constraints' do
    describe 'account_id' do
      it 'enforces non-null constraint' do
        subscription = create(:subscription)

        expect {
          subscription.update_column(:account_id, nil)
        }.to raise_error(ActiveRecord::NotNullViolation)
      end

      it 'enforces foreign key constraint' do
        subscription = create(:subscription)

        expect {
          subscription.update_column(:account_id, SecureRandom.uuid)
        }.to raise_error(ActiveRecord::InvalidForeignKey)
      end
    end

    describe 'product_id' do
      it 'enforces non-null constraint' do
        subscription = create(:subscription)

        expect {
          subscription.update_column(:product_id, nil)
        }.to raise_error(ActiveRecord::NotNullViolation)
      end

      it 'enforces foreign key constraint' do
        subscription = create(:subscription)

        expect {
          subscription.update_column(:product_id, SecureRandom.uuid)
        }.to raise_error(ActiveRecord::InvalidForeignKey)
      end
    end

    describe 'number_of_licenses' do
      it 'enforces non-null constraint' do
        subscription = create(:subscription)

        expect {
          subscription.update_column(:number_of_licenses, nil)
        }.to raise_error(ActiveRecord::NotNullViolation)
      end

      it 'enforces positive values through check constraint' do
        subscription = create(:subscription)

        expect {
          subscription.update_column(:number_of_licenses, 0)
        }.to raise_error(ActiveRecord::StatementInvalid, /check_positive_licenses/)
      end
    end

    describe 'issued_at' do
      it 'enforces non-null constraint' do
        subscription = create(:subscription)

        expect {
          subscription.update_column(:issued_at, nil)
        }.to raise_error(ActiveRecord::NotNullViolation)
      end
    end

    describe 'expires_at' do
      it 'enforces non-null constraint' do
        subscription = create(:subscription)

        expect {
          subscription.update_column(:expires_at, nil)
        }.to raise_error(ActiveRecord::NotNullViolation)
      end
    end

    describe 'unique account/product combination' do
      it 'enforces uniqueness through database constraint' do
        subscription = create(:subscription)
        new_subscription = subscription.dup

        expect {
          new_subscription.save(validate: false)
        }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end
end
