# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :account
  belongs_to :product

  validates :account_id, presence: true
  validates :product_id, presence: true
  validates :number_of_licenses, presence: true,
                               numericality: { only_integer: true, greater_than: 0 }
  validates :issued_at, presence: true
  validates :expires_at, presence: true

  validates :product_id, uniqueness: { scope: :account_id }

  validate :expires_at_after_issued_at

  def assigned_licenses_count
    LicenseAssignment.joins(:user)
                     .where(users: { account_id: account_id })
                     .where(product_id: product_id)
                     .count
  end

  def licenses_available
    number_of_licenses - assigned_licenses_count
  end

  def licenses_available?
    licenses_available.positive?
  end

  private

  def expires_at_after_issued_at
    return if issued_at.blank? || expires_at.blank?

    errors.add(:expires_at, :after_issued_at) if expires_at <= issued_at
  end
end
