class AddOpenAiRecommendationsToUploads < ActiveRecord::Migration[8.1]
  def change
    add_column :uploads, :open_ai_recommendations, :text
    add_column :uploads, :open_ai_analysis_status, :string
  end
end
