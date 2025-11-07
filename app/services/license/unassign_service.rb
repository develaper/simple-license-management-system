# frozen_string_literal: true

require "ostruct"

module License
  class UnassignService
    attr_reader :assignments, :error_messages

    def initialize(assignments)
      @assignments = assignments
      @error_messages = []
    end

    def call
      return not_found if @assignments.empty?

      ActiveRecord::Base.transaction do
        assignments.each do |assignment|
          unless assignment.destroy
            error_messages << "Failed to unassign license"
            raise ActiveRecord::Rollback
          end
        end

        return success_result
      end

      failure(error_messages)
    end

    private

    def not_found
      OpenStruct.new(
        success?: false,
        assignments_count: 0,
        error_messages: [ I18n.t("accounts.license_assignments.destroy.no_assignments_found") ]
      )
    end

    def success_result
      OpenStruct.new(
        success?: true,
        assignments_count: assignments.size,
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
