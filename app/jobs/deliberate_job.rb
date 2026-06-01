class DeliberateJob < ApplicationJob
  queue_as :default

  def perform(persona_id)
    persona = Persona.find(persona_id)
    focus_group = persona.focus_group
    return unless focus_group.deliberating?

    DeliberationServices::LlmRevise.new(model: persona.llm_model).call(
      persona: persona,
      peer_opinions: peer_opinions_for(persona)
    )

    advance_phase_if_last(focus_group)
  end

  def peer_opinions_for(persona)
    persona.focus_group.opinions
      .where(round: 0)
      .where.not(persona_id: persona.id)
      .includes(:persona)
      .to_a
  end

  private

  def advance_phase_if_last(focus_group)
    rows = FocusGroup
      .where(id: focus_group.id, status: FocusGroup.statuses[:deliberating])
      .where("(SELECT COUNT(*) FROM opinions WHERE focus_group_id = focus_groups.id AND round = 1) >= sample_size")
      .update_all(status: FocusGroup.statuses[:synthesizing])

    return if rows.zero?

    Rails.logger.info "[DeliberateJob] FocusGroup #{focus_group.id} — wszystkie round=1 opinie zebrane, status → synthesizing"
    ChairmanSynthesisJob.perform_later(focus_group.id)
  end
end
