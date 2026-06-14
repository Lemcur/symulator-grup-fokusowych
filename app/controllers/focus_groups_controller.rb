class FocusGroupsController < ApplicationController
  before_action :set_focus_group, only: [:show, :status, :approve]

  def index
    @focus_groups = current_user.focus_groups.includes(:product).order(created_at: :desc)
  end

  def show
  end

  def status
    render partial: "status", locals: { focus_group: @focus_group }
  end

  def approve
    unless @focus_group.awaiting_review?
      redirect_to @focus_group, alert: "Sesja nie jest w stanie oczekiwania na zatwierdzenie person." and return
    end

    if @focus_group.personas.empty?
      redirect_to @focus_group, alert: "Nie można zatwierdzić pustej grupy - dodaj co najmniej jedną personę." and return
    end

    @focus_group.update!(status: :collecting_opinions)
    @focus_group.personas.each { |p| CollectOpinionJob.perform_later(p.id) }
    redirect_to @focus_group, notice: "Persony zatwierdzone. Zbieranie opinii rozpoczęte."
  end

  def new
    @focus_group = current_user.focus_groups.build(
      sample_size: 12,
      generation_mode: "proportions",
      persona_generator: "llm_two_pass",
      target_demographics: {}
    )
    @products = current_user.products.order(:name)
  end

  def create
    @focus_group = current_user.focus_groups.build(focus_group_attributes)
    @focus_group.product = current_user.products.find_by(id: focus_group_params[:product_id])

    if structured_dimensions_complete? && @focus_group.save
      GeneratePersonasJob.perform_later(@focus_group.id)
      redirect_to @focus_group, notice: "Sesja utworzona. Generowanie person rozpoczęte."
    else
      @focus_group.valid? if @focus_group.errors.empty?
      add_structured_dimension_errors
      @products = current_user.products.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_focus_group
    @focus_group = current_user.focus_groups
      .includes(:product, :recommendation, personas: :opinions)
      .find(params[:id])
  end

  def focus_group_params
    permitted_dimensions = FocusGroup::DEMOGRAPHIC_SCHEMA.transform_values { |d| d[:buckets] }
    params.require(:focus_group).permit(
      :name, :product_id, :sample_size, :brief_summary, :additional_requirements,
      :persona_generator, :require_persona_review,
      :target_demographics,
      structured_demographics: permitted_dimensions
    )
  end

  def focus_group_attributes
    attrs = focus_group_params.to_h.except("product_id", "target_demographics", "structured_demographics")
    parsed = parsed_target_demographics
    attrs["target_demographics"] = parsed
    attrs["generation_mode"] = parsed.is_a?(Array) ? "slots" : "proportions"
    attrs
  end

  def parsed_target_demographics
    case params[:spec_mode]
    when "brief"
      {}
    when "structured"
      normalize_structured_demographics(focus_group_params[:structured_demographics])
    when "json"
      parse_raw_json(focus_group_params[:target_demographics])
    else
      {}
    end
  end

  def normalize_structured_demographics(raw)
    return {} if raw.blank?

    hash = raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw.to_h
    hash.each_with_object({}) do |(dimension, buckets), out|
      numeric = buckets.to_h.transform_values { |v| v.to_f.clamp(0, Float::INFINITY) }
      total = numeric.values.sum
      next if total.zero?

      normalized = numeric.transform_values { |v| v / total }.reject { |_, v| v.zero? }
      out[dimension.to_s] = normalized unless normalized.empty?
    end
  end

  def parse_raw_json(raw)
    return {} if raw.blank?

    JSON.parse(raw)
  rescue JSON::ParserError
    raw
  end

  def structured_dimensions_complete?
    return true unless params[:spec_mode] == "structured"

    missing_structured_dimensions.empty?
  end

  def missing_structured_dimensions
    configured = (@focus_group.target_demographics || {}).keys.map(&:to_s)
    FocusGroup::DEMOGRAPHIC_SCHEMA.keys - configured
  end

  def add_structured_dimension_errors
    return unless params[:spec_mode] == "structured"

    missing_structured_dimensions.each do |dim|
      label = FocusGroup::DEMOGRAPHIC_SCHEMA[dim][:label]
      @focus_group.errors.add(:base, "Wymiar \"#{label}\" musi mieć co najmniej jedną wagę większą od zera.")
    end
  end
end
