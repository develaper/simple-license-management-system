FactoryBot.define do
  factory :license_assignment do
    association :account
    association :user
    association :product
  end
end
