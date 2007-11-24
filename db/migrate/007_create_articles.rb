class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|

      # acts as filesystem
      t.column :name, :string
      t.column :slug, :string
      t.column :path, :text, :default => ''

      # main data
      t.column :body, :text

      # belongs to profile
      t.column :profile_id, :integer

      # acts as tree
      t.column :parent_id, :integer

      # keep track of timestamps
      t.column :updated_on,  :datetime
      t.column :created_on,  :datetime 

      # versioning stuff
      t.column :version, :integer
      t.column :lock_version, :integer
    end

    Article.create_versioned_table
  end

  def self.down
    Article.drop_versioned_table
    drop_table :articles
  end
end
