# frozen_string_literal: true

module License
  class UsersQuery
    attr_reader :account, :user_ids

    def initialize(account, user_ids)
      @account = account
      @user_ids = user_ids
    end

    def call
      users = account.users.where(id: user_ids)
      raise ActiveRecord::RecordNotFound, I18n.t("accounts.license_assignments.create.invalid_users") if invalid_selection?(users)

      users
    end

    private

    def invalid_selection?(users)
      users.size != user_ids.size
    end
  end
end
