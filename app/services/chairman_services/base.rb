module ChairmanServices
  class Base
    def call(focus_group:)
      raise NotImplementedError
    end

    private

    def create_recommendation(focus_group:, data:, llm_model:, llm_provider:)
      rating_distribution = focus_group.opinions
        .round_one
        .group(:rating)
        .count
        .transform_keys(&:to_s)

      Recommendation.create!(
        focus_group: focus_group,
        summary: data.fetch("summary"),
        strengths: data.fetch("strengths"),
        weaknesses: data.fetch("weaknesses"),
        rating_distribution: rating_distribution,
        agreement_points: data.fetch("agreement_points"),
        persuasive_arguments: data.fetch("persuasive_arguments"),
        persistent_divisions: data.fetch("persistent_divisions"),
        segment_insights: data.fetch("segment_insights"),
        generated_at: Time.current
      )
    end
  end
end
