class CreateSearchTermOccurrences < ActiveRecord::Migration
  def up
    create_table :search_term_occurrences do |t|
      t.references   :search_term
      t.datetime     :created_at
      t.integer      :total, :default => 0
      t.integer      :indexed, :default => 0
    end
    add_index :search_term_occurrences, :created_at
  end

  def down
    remove_index :search_term_occurrences, :created_at
    drop_table :search_term_occurrences
  end
end
