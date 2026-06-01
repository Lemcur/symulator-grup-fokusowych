class Persona < ApplicationRecord
  belongs_to :focus_group

  has_many :opinions, dependent: :destroy

  validates :name, presence: true
  validates :description, presence: true

  def round_zero_opinion
    opinions.round_zero.first
  end

  def round_one_opinion
    opinions.round_one.first
  end
end
