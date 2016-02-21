class AddVirtualFlagToCategorizations < ActiveRecord::Migration
  def self.up
    add_column :articles_categories, :virtual, :boolean, :default => false
    execute('update articles_categories set virtual = (1!=1)')
    Article.find_each do |article|
      article.category_ids = article.categories.map(&:id)
    end

    add_column :categories_profiles, :virtual, :boolean, :default => false
    execute('update categories_profiles set virtual = (1!=1)')
    Profile.find_each do |profile|
      profile.category_ids = profile.categories.map(&:id)
    end
  end

  def self.down
    remove_column :articles_categories, :virtual
    remove_column :categories_profiles, :virtual
  end
end
