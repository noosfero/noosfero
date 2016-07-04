class AddTypeToPolymorphicProfileAssociations < ActiveRecord::Migration
  def up
    add_column :tasks, :reported_type, :string
    add_column :abuse_reports, :reporter_type, :string
    add_column :comments, :author_type, :string

    update("UPDATE tasks SET reported_type='Profile'")
    update("UPDATE abuse_reports SET reporter_type='Person'")
    update("UPDATE comments SET author_type='Person'")
  end

  def down
    remove_column :abuse_complaints, :reported_type
    remove_column :abuse_reports, :reporter_type
    remove_column :comments, :author_type
  end
end
