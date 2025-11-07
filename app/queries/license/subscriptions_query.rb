# frozen_string_literal: true

module License
  class SubscriptionsQuery
    attr_reader :account, :subscription_ids, :needed_licenses

    def initialize(account, subscription_ids, needed_licenses)
      @account = account
      @subscription_ids = subscription_ids
      @needed_licenses = needed_licenses
    end

    def call
      raise ActiveRecord::RecordNotFound if subscription_ids.empty?
      subscriptions = account.subscriptions.find(subscription_ids)
      validate_availability!(subscriptions)

      subscriptions
    end

    private

    def validate_availability!(subscriptions)
      insufficient = insufficient_subscriptions(subscriptions)
      return unless insufficient.any?

      error_messages = insufficient.map do |subscription|
        I18n.t("accounts.license_assignments.create.insufficient_licenses",
          product: subscription.product.name,
          available: subscription.licenses_available,
          needed: needed_licenses)
      end

      raise ActiveRecord::RecordNotFound, error_messages.to_sentence
    end

    def insufficient_subscriptions(subscriptions)
      subscriptions.select { |subscription| subscription.licenses_available < needed_licenses }
    end
  end
end
