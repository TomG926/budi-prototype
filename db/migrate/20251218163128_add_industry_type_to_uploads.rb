class AddIndustryTypeToUploads < ActiveRecord::Migration[8.1]
  def change
    add_column :uploads, :industry_type, :string
  end
end
