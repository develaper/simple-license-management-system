require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:product)).to be_valid
    end
  end

  describe 'validations' do
    describe 'name' do
      context 'when name is not present' do
        it 'is not valid' do
          product = build(:product, name: nil)
          expect(product).not_to be_valid
          expect(product.errors[:name]).to include("can't be blank")
        end
      end

      context 'when name is present' do
        it 'is valid' do
          product = build(:product, name: 'Test Product')
          expect(product).to be_valid
        end
      end
    end

    describe 'description' do
      context 'when description is not present' do
        it 'is still valid' do
          product = build(:product, description: nil)
          expect(product).to be_valid
        end
      end

      context 'when description is present' do
        it 'is valid' do
          product = build(:product, description: 'Test Description')
          expect(product).to be_valid
        end
      end
    end
  end

  describe 'database constraints' do
    context 'when name is null' do
      it 'raises an error' do
        product = build(:product, name: nil)
        expect { product.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
      end
    end
  end
end
