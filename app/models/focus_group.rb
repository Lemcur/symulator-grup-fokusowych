class FocusGroup < ApplicationRecord
  belongs_to :product
  belongs_to :user

  has_many :personas, dependent: :destroy
  has_many :opinions, through: :personas
  has_one :chairman, dependent: :destroy
  has_one :recommendation, dependent: :destroy

  enum :status, {
    pending: 0,
    generating_personas: 1,
    collecting_opinions: 2,
    deliberating: 3,
    synthesizing: 4,
    completed: 5,
    failed: 6
  }

  enum :generation_mode, {
    proportions: 0,
    slots: 1
  }

  enum :persona_generator, {
    llm_single_pass: 0,
    llm_two_pass: 1
  }

  validates :name, presence: true
  validates :sample_size, numericality: { only_integer: true, greater_than: 0 }
  validate :target_demographics_matches_mode

  def expand_slots
    case generation_mode
    when "proportions" then sample_from_proportions
    when "slots"       then expand_explicit_slots
    end
  end

  def progress
    return 0.0 if sample_size.to_i.zero?

    case status
    when "pending", "generating_personas"
      personas.count.to_f / sample_size
    when "collecting_opinions"
      opinions.where(round: 0).count.to_f / sample_size
    when "deliberating"
      opinions.where(round: 1).count.to_f / sample_size
    when "synthesizing"
      0.95
    when "completed"
      1.0
    else
      0.0
    end
  end

  def all_agents_done?
    opinions.where(round: 0).count >= sample_size
  end

  def all_deliberations_done?
    opinions.where(round: 1).count >= sample_size
  end

  private

  def target_demographics_matches_mode
    return if target_demographics.nil?

    case generation_mode
    when "proportions"
      unless target_demographics.is_a?(Hash)
        errors.add(:target_demographics, "musi być hashem dla trybu proportions")
      end
    when "slots"
      unless target_demographics.is_a?(Array)
        errors.add(:target_demographics, "musi być tablicą dla trybu slots")
        return
      end
      total = target_demographics.sum { |s| s["count"].to_i }
      if total != sample_size
        errors.add(:target_demographics, "suma count (#{total}) musi równać się sample_size (#{sample_size})")
      end
    end
  end

  def sample_from_proportions
    Array.new(sample_size) do
      target_demographics.each_with_object({}) do |(dimension, distribution), slot|
        slot[dimension] = weighted_sample(distribution)
      end
    end
  end

  def expand_explicit_slots
    target_demographics.flat_map do |slot|
      count = slot["count"].to_i
      attrs = slot.except("count")
      Array.new(count) { attrs.dup }
    end
  end

  def weighted_sample(distribution)
    cumulative = 0.0
    roll = rand
    distribution.each do |option, weight|
      cumulative += weight.to_f
      return option if roll < cumulative
    end
    distribution.keys.last
  end
end
