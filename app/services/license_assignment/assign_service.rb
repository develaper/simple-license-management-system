# frozen_string_literal: true

require "ostruct"

module License
  class AssignService
    attr_reader :account, :users, :subscriptions, :error_messages

    def initialize(account:, users:, subscriptions:)
      @account = account
      @users = users
      @subscriptions = subscriptions
      @error_messages = []
    end

    def call
      return failure(duplicate_error_messages) if duplicate_assignments.any?

      ActiveRecord::Base.transaction do
        assignments_to_create.each do |assignment_attrs|
          license_assignment = account.license_assignments.build(assignment_attrs)

          unless license_assignment.save
            error_messages << license_assignment.errors.full_messages
            raise ActiveRecord::Rollback
          end
        end

        return success_result
      end

      failure(error_messages)
    end

    private

    def duplicate_assignments
      @duplicate_assignments ||= find_duplicate_assignments
    end

    def find_duplicate_assignments
      duplicates = []
      subscriptions.each do |subscription|
        users.each do |user|
          if LicenseAssignment.exists?(user: user, product: subscription.product)
            duplicates << { user: user.name, product: subscription.product.name }
          end
        end
      end
      duplicates
    end

    def assignments_to_create
      @assignments_to_create ||= begin
        assignments = []
        subscriptions.each do |subscription|
          users.each do |user|
            unless LicenseAssignment.exists?(user: user, product: subscription.product)
              assignments << { user: user, product: subscription.product }
            end
          end
        end
        assignments
      end
    end

    def duplicate_error_messages
      duplicate_assignments.map do |da|
        I18n.t("accounts.license_assignments.create.duplicate_assignment",
               user: da[:user], product: da[:product])
      end
    end

    def success_result
      OpenStruct.new(
        success?: true,
        assignments_count: assignments_to_create.size,
        error_messages: []
      )
    end

    def failure(messages)
      OpenStruct.new(
        success?: false,
        assignments_count: 0,
        error_messages: Array(messages).flatten
      )
    end
  end
end
