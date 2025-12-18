class CreateUploads < ActiveRecord::Migration[8.1]
  def change
    create_table :uploads do |t|
      t.string :name
      t.string :status

      t.timestamps
    end
  end
end
