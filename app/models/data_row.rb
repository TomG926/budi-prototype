class DataRow < ApplicationRecord
  belongs_to :upload

  # Store flexible data as JSONB
  # Access it like: data_row.data["column_name"]
  validates :data, presence: true
end

