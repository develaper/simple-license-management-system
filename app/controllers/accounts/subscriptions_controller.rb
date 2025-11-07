# frozen_string_literal: true

module Accounts
  class SubscriptionsController < ApplicationController
    before_action :set_account
    before_action :set_subscription, only: [ :show, :edit, :update, :destroy ]
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

    def index
      @subscriptions = @account.subscriptions.includes(:product)
    end

    def show; end

    def new
      @subscription = @account.subscriptions.build
      @products = Product.all
    end

    def create
      @subscription = @account.subscriptions.build(subscription_params)

      if @subscription.save
        redirect_after_action(@subscription, :created)
      else
        @products = Product.all
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @products = Product.all
    end

    def update
      if @subscription.update(subscription_params)
        redirect_after_action(@subscription, :updated)
      else
        @products = Product.all
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @subscription.destroy
      redirect_after_action(@subscription, :deleted)
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end

    def set_subscription
      @subscription = @account.subscriptions.find(params[:id])
    end

    def subscription_params
      params.require(:subscription).permit(:product_id, :number_of_licenses, :issued_at, :expires_at)
    end

    def redirect_after_action(subscription, action)
      redirect_to account_subscriptions_path(@account), notice: t("accounts.subscriptions.#{action}")
    end

    def handle_not_found(exception)
      redirect_to account_subscriptions_path(@account), alert: t("accounts.subscriptions.not_found", resource: "Subscription")
    end
  end
end
