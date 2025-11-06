class ProductsController < ApplicationController
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

  def index
    @products = Product.all
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_after_action(@product, :created)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_after_action(@product, :updated)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_after_action(products_path, :deleted)
  end

  private

  def product_params
    params.require(:product).permit(:name, :description)
  end

  def set_product
    @product = Product.find(params[:id])
  end

  def handle_not_found
    flash[:alert] = t("products.not_found", resource: "Product")
    redirect_to products_path
  end

  def redirect_after_action(destination, action)
    redirect_to destination, notice: t("products.#{action}")
  end
end
