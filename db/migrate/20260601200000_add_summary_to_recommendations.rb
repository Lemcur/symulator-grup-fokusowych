class AddSummaryToRecommendations < ActiveRecord::Migration[8.1]
  def change
    add_column :recommendations, :summary, :text
  end
end
