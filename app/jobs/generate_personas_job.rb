class GeneratePersonasJob < ApplicationJob
  queue_as :default

  MODEL_SPLIT = ["gpt-4o-mini", "claude-haiku-4-5"].freeze

  GENERATOR_BY_ENUM = {
    "llm_single_pass" => PersonaGenerators::LlmTwoPassRefine,
    "llm_two_pass"    => PersonaGenerators::LlmTwoPassRefine
  }.freeze

  def perform(focus_group_id)
    focus_group = FocusGroup.find(focus_group_id)
    return unless focus_group.pending?

    focus_group.update!(status: :generating_personas, started_at: Time.current)

    generator_class = GENERATOR_BY_ENUM.fetch(focus_group.persona_generator)
    slots = focus_group.expand_slots

    slots.each_with_index do |slot, index|
      model = MODEL_SPLIT[index % MODEL_SPLIT.size]
      context = build_previous_context(focus_group)

      generator_class.new(model: model).call(
        focus_group: focus_group,
        slot_demographics: slot,
        previous_context: context
      )
    end

    if focus_group.require_persona_review?
      focus_group.update!(status: :awaiting_review)
      Rails.logger.info "[GeneratePersonasJob] FocusGroup #{focus_group.id} — #{slots.size} person gotowych, status → awaiting_review"
      return
    end

    focus_group.update!(status: :collecting_opinions)
    Rails.logger.info "[GeneratePersonasJob] FocusGroup #{focus_group.id} — #{slots.size} person gotowych, status → collecting_opinions"

    focus_group.personas.each do |persona|
      CollectOpinionJob.perform_later(persona.id)
    end
  end

  private

  def build_previous_context(focus_group)
    personas = focus_group.personas.order(:created_at)
    return "" if personas.empty?

    lines = personas.map.with_index(1) do |p, i|
      "#{i}. #{p.name} (#{p.demographics['wiek']}, #{p.demographics['miasto']}, #{p.demographics['zawod']})"
    end

    <<~CONTEXT
      DOTYCHCZAS ZAPROJEKTOWANI UCZESTNICY GRUPY (#{personas.size}/#{focus_group.sample_size}):
      #{lines.join("\n")}

      Zaprojektuj kogoś WYRAŹNIE INNEGO od powyższych — inne imię (nie powtarzaj nazwisk),
      inne miasto jeśli to możliwe, inny typ zawodu, inny styl komunikacji.
      Grupa fokusowa potrzebuje różnorodnych perspektyw.
    CONTEXT
  end
end
