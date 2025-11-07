class Product < ApplicationRecord
  has_many :subscriptions, dependent: :destroy

  validates :name, presence: true
end
