class Chairman < ApplicationRecord
  belongs_to :focus_group

  validates :llm_model, presence: true
  validates :focus_group_id, uniqueness: true
end
