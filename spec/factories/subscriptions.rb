# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    association :account
    association :product
    number_of_licenses { Faker::Number.between(from: 1, to: 100) }
    issued_at { Time.current }
    expires_at { 1.year.from_now }

    trait :without_account do
      account { nil }
    end

    trait :without_product do
      product { nil }
    end
  end
end
