class CreateDataQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :data_questions do |t|
      t.references :upload, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :question
      t.text :answer

      t.timestamps
    end
  end
end
