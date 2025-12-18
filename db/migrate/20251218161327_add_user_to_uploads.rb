class AddUserToUploads < ActiveRecord::Migration[8.1]
  def up
    # First, add the column allowing null
    add_reference :uploads, :user, null: true, foreign_key: true
    
    # Delete any existing uploads without a user (clean slate for user-scoped data)
    # Must delete data_rows first due to foreign key constraint
    # If you want to keep existing uploads, assign them to a default user instead:
    # default_user = User.first_or_create!(email: 'admin@example.com', password: 'changeme')
    # Upload.where(user_id: nil).update_all(user_id: default_user.id)
    
    # Delete orphaned data_rows first (for uploads that will be deleted)
    execute <<-SQL
      DELETE FROM data_rows 
      WHERE upload_id IN (SELECT id FROM uploads WHERE user_id IS NULL)
    SQL
    
    # Now delete the orphaned uploads
    execute <<-SQL
      DELETE FROM uploads WHERE user_id IS NULL
    SQL
    
    # Now add the not-null constraint
    change_column_null :uploads, :user_id, false
  end
  
  def down
    remove_reference :uploads, :user, foreign_key: true
  end
end
