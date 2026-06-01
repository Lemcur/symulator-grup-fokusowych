class Opinion < ApplicationRecord
  belongs_to :persona
  belongs_to :focus_group

  enum :status, {
    pending: 0,
    collected: 1,
    failed: 2
  }

  scope :round_zero, -> { where(round: 0) }
  scope :round_one,  -> { where(round: 1) }

  validates :round, inclusion: { in: [0, 1] }
  validates :persona_id, uniqueness: { scope: :round }
end
