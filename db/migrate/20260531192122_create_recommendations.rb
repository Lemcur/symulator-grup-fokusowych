class CreateRecommendations < ActiveRecord::Migration[8.1]
  def change
    create_table :recommendations do |t|
      t.jsonb :strengths
      t.jsonb :weaknesses
      t.jsonb :rating_distribution
      t.jsonb :segment_insights
      t.jsonb :agreement_points
      t.jsonb :persuasive_arguments
      t.jsonb :persistent_divisions
      t.datetime :generated_at
      t.references :focus_group, null: false, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
