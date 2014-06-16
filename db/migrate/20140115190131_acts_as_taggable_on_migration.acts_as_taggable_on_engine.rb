# This migration comes from acts_as_taggable_on_engine (originally 1)
class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    change_table :taggings do |t|
      t.references :tagger, :polymorphic => true
      t.string :context, :limit => 128
    end
    add_index :taggings, [:taggable_id, :taggable_type, :context]
  end

  def self.down
    remove_index :taggings, [:taggable_id, :taggable_type, :context]
    change_table :taggings do |t|
      t.remove_references :tagger, :polymorphic => true
      t.remove :context
    end
  end
end
