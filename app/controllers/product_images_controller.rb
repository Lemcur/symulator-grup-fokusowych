class ProductImagesController < ApplicationController
  def destroy
    product = current_user.products.find(params[:product_id])
    blob = ActiveStorage::Blob.find_signed!(params[:id])
    attachment = product.images.attachments.find_by(blob: blob)

    if attachment.nil?
      redirect_to edit_product_path(product), alert: "Zdjęcie nie należy do tego produktu." and return
    end

    attachment.purge_later
    redirect_to edit_product_path(product), notice: "Zdjęcie usunięte."
  rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
    redirect_to products_path, alert: "Nie znaleziono zdjęcia."
  end
end
