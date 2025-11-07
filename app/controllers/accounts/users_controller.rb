module Accounts
  class UsersController < ApplicationController
    before_action :set_account
    before_action :set_user, only: [ :edit, :update, :destroy ]
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

    def index
      @users = @account.users
    end

    def new
      @user = @account.users.build
    end

    def create
      @user = @account.users.build(user_params)

      if @user.save
        redirect_after_action(@user, :created)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_after_action(@user, :updated)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_after_action(@user, :deleted)
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end

    def set_user
      @user = @account.users.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email)
    end

    def redirect_after_action(user, action)
      redirect_to account_path(@account), notice: t("accounts.users.#{action}")
    end

    def handle_not_found(exception)
      redirect_to root_path, alert: t("accounts.users.not_found", resource: exception.model)
    end
  end
end
