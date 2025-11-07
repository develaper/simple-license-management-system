# frozen_string_literal: true

module License
  class AssignmentsForUnassignQuery
    attr_reader :account, :user_ids, :product_id

    def initialize(account, user_ids, product_id)
      @account = account
      @user_ids = user_ids
      @product_id = product_id
    end

    def call
      assignments = account.license_assignments
        .where(user_id: user_ids)
        .where(product_id: product_id)

      raise ActiveRecord::RecordNotFound, I18n.t("accounts.license_assignments.destroy.no_assignments_found") if assignments.empty?

      assignments
    end
  end
end
