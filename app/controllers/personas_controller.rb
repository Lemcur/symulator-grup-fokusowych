class PersonasController < ApplicationController
  before_action :set_focus_group
  before_action :ensure_awaiting_review
  before_action :set_persona, only: [:edit, :update, :destroy]

  def new
    @persona = @focus_group.personas.build
  end

  def create
    @persona = @focus_group.personas.build(persona_attributes)

    if @persona.save
      redirect_to @focus_group, notice: "Persona dodana."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @persona.update(persona_attributes)
      redirect_to @focus_group, notice: "Persona zaktualizowana."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @persona.destroy!
    redirect_to @focus_group, notice: "Persona usunięta."
  end

  private

  def set_focus_group
    @focus_group = current_user.focus_groups.find(params[:focus_group_id])
  end

  def set_persona
    @persona = @focus_group.personas.find(params[:id])
  end

  def ensure_awaiting_review
    return if @focus_group.awaiting_review?

    redirect_to @focus_group, alert: "Persony można edytować tylko w stanie oczekiwania na zatwierdzenie."
  end

  def persona_params
    params.require(:persona).permit(:name, :description, :demographics, :traits)
  end

  def persona_attributes
    attrs = persona_params.to_h.except("demographics", "traits")
    attrs["demographics"] = parsed_json(persona_params[:demographics])
    attrs["traits"]       = parsed_json(persona_params[:traits])
    attrs
  end

  def parsed_json(raw)
    return {} if raw.blank?

    JSON.parse(raw)
  rescue JSON::ParserError
    raw
  end
end
