class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = current_user.products.order(created_at: :desc)
  end

  def show
  end

  def new
    @product = current_user.products.build
  end

  def create
    attrs = product_params
    new_images = Array(attrs.delete(:images)).reject(&:blank?)

    @product = current_user.products.build(attrs)
    @product.images.attach(new_images) if new_images.any?

    if @product.save
      redirect_to @product, notice: "Produkt utworzony."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attrs = product_params
    new_images = Array(attrs.delete(:images)).reject(&:blank?)

    @product.assign_attributes(attrs)
    @product.images.attach(new_images) if new_images.any?

    if @product.save
      redirect_to @product, notice: "Produkt zaktualizowany."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: "Produkt usunięty."
  end

  private

  def set_product
    @product = current_user.products.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, images: [])
  end
end
