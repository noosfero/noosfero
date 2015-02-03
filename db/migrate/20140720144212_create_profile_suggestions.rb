class CreateProfileSuggestions < ActiveRecord::Migration
  def change
    create_table :profile_suggestions do |t|
      t.references :person
      t.references :suggestion
      t.string :suggestion_type
      t.text :categories
      t.boolean :enabled, :default => true
      t.float :score, :default => 0

      t.timestamps
    end
    add_index :profile_suggestions, :person_id
    add_index :profile_suggestions, :suggestion_id
    add_index :profile_suggestions, :score
  end
end
