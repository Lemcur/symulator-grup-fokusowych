class FocusGroupsController < ApplicationController
  before_action :set_focus_group, only: [:show, :status]

  def index
    @focus_groups = current_user.focus_groups.includes(:product).order(created_at: :desc)
  end

  def show
  end

  def status
    render partial: "status", locals: { focus_group: @focus_group }
  end

  def new
    @focus_group = current_user.focus_groups.build(
      sample_size: 12,
      generation_mode: "proportions",
      persona_generator: "llm_two_pass",
      target_demographics: default_target_demographics
    )
    @products = current_user.products.order(:name)
  end

  def create
    product = current_user.products.find(focus_group_params[:product_id])
    @focus_group = product.focus_groups.build(focus_group_attributes.merge(user: current_user))

    if @focus_group.save
      GeneratePersonasJob.perform_later(@focus_group.id)
      redirect_to @focus_group, notice: "Sesja utworzona. Generowanie person rozpoczęte."
    else
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
    params.require(:focus_group).permit(
      :name, :product_id, :sample_size, :generation_mode,
      :persona_generator, :target_demographics
    )
  end

  def focus_group_attributes
    attrs = focus_group_params.to_h.except("product_id", "target_demographics")
    attrs["target_demographics"] = parsed_target_demographics
    attrs
  end

  def parsed_target_demographics
    raw = focus_group_params[:target_demographics]
    return default_target_demographics if raw.blank?

    JSON.parse(raw)
  rescue JSON::ParserError
    raw
  end

  def default_target_demographics
    {
      "wiek" => { "25-29" => 0.4, "30-34" => 0.6 },
      "plec" => { "kobieta" => 1.0 },
      "miejsce_zamieszkania" => { "duze_miasto" => 0.7, "srednie_miasto" => 0.3 }
    }
  end
end
