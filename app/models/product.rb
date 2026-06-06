class Product < ApplicationRecord
  MAX_IMAGES = 3
  MAX_IMAGE_SIZE = 5.megabytes
  ALLOWED_IMAGE_TYPES = %w[image/png image/jpeg image/webp image/gif].freeze

  belongs_to :user

  has_many :focus_groups, dependent: :destroy
  has_many_attached :images

  validates :name, presence: true
  validates :description, presence: true
  validate :images_count_within_limit
  validate :images_have_allowed_content_type
  validate :images_within_size_limit

  private

  def images_count_within_limit
    return if images.count <= MAX_IMAGES
    errors.add(:images, "maksymalnie #{MAX_IMAGES} zdjęć (jest #{images.count})")
  end

  def images_have_allowed_content_type
    images.each do |image|
      next if ALLOWED_IMAGE_TYPES.include?(image.content_type)
      errors.add(:images, "niedozwolony typ pliku: #{image.content_type} (dozwolone: PNG, JPEG, WEBP, GIF)")
    end
  end

  def images_within_size_limit
    images.each do |image|
      next if image.byte_size <= MAX_IMAGE_SIZE
      errors.add(:images, "plik #{image.filename} przekracza #{MAX_IMAGE_SIZE / 1.megabyte} MB")
    end
  end
end
