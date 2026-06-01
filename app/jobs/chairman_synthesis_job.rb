class ChairmanSynthesisJob < ApplicationJob
  queue_as :default

  CHAIRMAN_MODEL = "claude-sonnet-4-6".freeze

  def perform(focus_group_id)
    focus_group = FocusGroup.find(focus_group_id)
    return unless focus_group.synthesizing?

    focus_group.update!(synthesis_started_at: Time.current)

    Chairman.find_or_create_by!(focus_group: focus_group) do |c|
      c.llm_model = CHAIRMAN_MODEL
      c.role = "synthesizer"
    end

    ChairmanServices::LlmSynthesize.new(model: CHAIRMAN_MODEL).call(focus_group: focus_group)

    focus_group.update!(status: :completed, completed_at: Time.current)
    Rails.logger.info "[ChairmanSynthesisJob] FocusGroup #{focus_group.id} — rekomendacja wygenerowana, status → completed"
  end
end
