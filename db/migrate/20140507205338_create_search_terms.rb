class CreateSearchTerms < ActiveRecord::Migration
  def up
    create_table :search_terms do |t|
      t.string      :term
      t.references  :context, :polymorphic => true
      t.string      :asset, :default => 'all'
      t.float       :score, :default => 0
      t.float       :relevance_score, :default => 0
      t.float       :occurrence_score, :default => 0
    end

    add_index :search_terms, :term
    add_index :search_terms, :asset
    add_index :search_terms, :score
    add_index :search_terms, :relevance_score
    add_index :search_terms, :occurrence_score
  end

  def down
    remove_index :search_terms, :term
    remove_index :search_terms, :asset
    remove_index :search_terms, :score
    remove_index :search_terms, :relevance_score
    remove_index :search_terms, :occurrence_score
    drop_table :search_terms
  end
end
