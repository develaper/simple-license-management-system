# frozen_string_literal: true

module Accounts
  class LicenseAssignmentsController < ApplicationController
    before_action :set_account
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

    def new
      @license_assignments = @account.license_assignments
      @subscriptions = @account.subscriptions.includes(:product)
      @available_users = @account.users
    end

    def create
      users = License::UsersQuery.new(@account, license_assignment_params[:user_ids]).call
      subscriptions = License::SubscriptionsQuery.new(
        @account,
        license_assignment_params[:subscription_ids],
        users.size
      ).call

      result = License::AssignService.new(
        account: @account,
        users: users,
        subscriptions: subscriptions
      ).call

      redirect_after_action(result, "create.success")
    end

    def destroy
      assignments = License::AssignmentsForUnassignQuery.new(
        @account,
        unassignment_params[:user_ids],
        unassignment_params[:product_id]
      ).call

      result = License::UnassignService.new(assignments).call
      redirect_after_action(result, "destroy.success")
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end

    def license_assignment_params
      params.require(:license_assignment).permit(subscription_ids: [], user_ids: [])
    end

    def unassignment_params
      params.require(:license_assignment).permit(:product_id, user_ids: [])
    end

    def redirect_after_action(result, action)
      if result.success?
        redirect_to account_path(@account), notice: t("accounts.license_assignments.#{action}")
      else
        @license_assignments = @account.license_assignments
        @subscriptions = @account.subscriptions.includes(:product)
        @available_users = @account.users
        flash.now[:alert] = result.error_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end

    def handle_not_found(exception)
      redirect_to account_path(@account), alert: t("shared.not_found", resource: exception.model)
    end
  end
end
