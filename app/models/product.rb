class Product < ApplicationRecord
  belongs_to :user

  has_many :focus_groups, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true
end
