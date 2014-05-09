class CreateSearchTerms < ActiveRecord::Migration
  def up
    create_table :search_terms do |t|
      t.string      :term
      t.references  :context, :polymorphic => true
      t.string      :asset, :default => 'all'
      t.float       :score, :default => 0
    end

    add_index :search_terms, [:term, :asset, :score]
  end

  def down
    remove_index :search_terms, [:term, :asset, :score]
    drop_table :search_terms
  end
end
