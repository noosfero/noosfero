class CreateOrganizationRatingsConfig < ActiveRecord::Migration

  def change
    create_table :organization_ratings_configs do |t|
     t.belongs_to :environment
     t.integer :cooldown, :integer, :default => 24
     t.integer :default_rating, :integer, :default => 1
     t.string  :order, :string, :default => "recent"
     t.integer :per_page, :integer, :default => 10
     t.boolean :vote_once, :boolean, :default => false
     t.boolean :are_moderated, :boolean, :default => true
    end
  end
end
