class Recommendation < ApplicationRecord
  belongs_to :focus_group

  validates :focus_group_id, uniqueness: true
end
