class Upload < ApplicationRecord
  belongs_to :user
  has_one_attached :file
  has_many :data_rows, dependent: :destroy
  has_many :data_questions, dependent: :destroy

  enum :status, { pending: "pending", processing: "processing", done: "done", failed: "failed" }, default: :pending
  
  enum :open_ai_analysis_status, { 
    not_started: "not_started", 
    analyzing: "analyzing", 
    completed: "completed", 
    analysis_failed: "analysis_failed" 
  }, default: :not_started
  
  enum :industry_type, {
    salon: "salon",
    retail: "retail",
    restaurant: "restaurant",
    healthcare: "healthcare",
    professional_services: "professional_services",
    ecommerce: "ecommerce",
    fitness: "fitness",
    education: "education",
    other: "other"
  }, default: :other

  # Store the CSV column names and types for Power BI schema
  # Example: { "date" => "DateTime", "amount" => "Double", "product" => "String" }
  def schema_columns
    super || {}
  end

  def has_power_bi_integration?
    power_bi_dataset_id.present? && power_bi_table_name.present?
  end
end
