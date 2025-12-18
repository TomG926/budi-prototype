class CreateDataRows < ActiveRecord::Migration[8.1]
  def change
    create_table :data_rows do |t|
      t.references :upload, null: false, foreign_key: true
      t.jsonb :data, null: false, default: {}
      t.string :power_bi_dataset_id
      t.string :power_bi_table_name

      t.timestamps
    end

    add_index :data_rows, :data, using: :gin
    add_index :data_rows, :power_bi_dataset_id
  end
end
