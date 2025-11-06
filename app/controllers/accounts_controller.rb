class AccountsController < ApplicationController
  before_action :set_account, only: [ :show, :edit, :update, :destroy ]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  def index
    @accounts = Account.all
  end

  def show
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)

    if @account.save
      redirect_after_action(@account, :created)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @account.update(account_params)
      redirect_after_action(@account, :updated)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @account.destroy
    redirect_after_action(accounts_path, :deleted)
  end

  private

  def account_params
    params.require(:account).permit(:name)
  end

  def set_account
    @account = Account.find(params[:id])
  end

  def handle_not_found
    flash[:alert] = t(".not_found", resource: "Account")
    redirect_to accounts_path
  end

  def redirect_after_action(destination, action)
    redirect_to destination, notice: t(".#{action}")
  end
end
