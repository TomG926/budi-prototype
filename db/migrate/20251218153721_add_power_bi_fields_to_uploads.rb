class AddPowerBiFieldsToUploads < ActiveRecord::Migration[8.1]
  def change
    add_column :uploads, :power_bi_dataset_id, :string
    add_column :uploads, :power_bi_table_name, :string
    add_column :uploads, :power_bi_workspace_id, :string
    add_column :uploads, :schema_columns, :jsonb
  end
end
