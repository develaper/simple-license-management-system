class LicenseAssignment < ApplicationRecord
  belongs_to :account
  belongs_to :user
  belongs_to :product

  validate :user_belongs_to_account

  private

  def user_belongs_to_account
    errors.add(:user, "must belong to the same account") unless user&.account_id == account_id
  end
end
