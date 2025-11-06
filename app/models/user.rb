class User < ApplicationRecord
  belongs_to :account

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
                   format: { with: URI::MailTo::EMAIL_REGEXP }
end
