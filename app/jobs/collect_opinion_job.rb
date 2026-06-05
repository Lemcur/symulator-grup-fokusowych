class CollectOpinionJob < ApplicationJob
  queue_as :default

  def perform(persona_id)
    persona = Persona.find(persona_id)
    focus_group = persona.focus_group
    return unless focus_group.collecting_opinions?

    OpinionCollectors::LlmBasic.new(model: persona.llm_model).call(persona: persona)

    advance_phase_if_last(focus_group)
  end

  private

  def advance_phase_if_last(focus_group)
    rows = FocusGroup
      .where(id: focus_group.id, status: FocusGroup.statuses[:collecting_opinions])
      .where("(SELECT COUNT(*) FROM opinions WHERE focus_group_id = focus_groups.id AND round = 0) >= sample_size")
      .update_all(status: FocusGroup.statuses[:deliberating])

    return if rows.zero?

    Rails.logger.info "[CollectOpinionJob] FocusGroup #{focus_group.id} - wszystkie round=0 opinie zebrane, status → deliberating"

    focus_group.personas.each do |persona|
      DeliberateJob.perform_later(persona.id)
    end
  end
end
