class LicenseAssignment < ApplicationRecord
  belongs_to :account
  belongs_to :user
  belongs_to :product

  validate :user_belongs_to_account
  validate :no_duplicate_product_assignment

  private

  def no_duplicate_product_assignment
    if user && product && LicenseAssignment.exists?(user: user, product: product)
      errors.add(:base, :duplicate_assignment, user: user.name, product: product.name)
    end
  end

  def user_belongs_to_account
    errors.add(:user, "must belong to the same account") unless user&.account_id == account_id
  end
end
