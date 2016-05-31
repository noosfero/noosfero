class AddInitialPageToOrganizationRatingsConfig < ActiveRecord::Migration
  def up
    add_column :organization_ratings_configs, :ratings_on_initial_page, :integer, :default => 3
  end

  def down
    remove_column :organization_ratings_configs, :ratings_on_initial_page
  end
end
