class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|

      # acts as filesystem
      t.column :title, :string
      t.column :body, :text

      # belongs to an article
      t.column :article_id, :integer

      # belongs to a person, maybe unauthenticated
      t.column :author_id, :integer
      t.column :name, :string
      t.column :email, :string

      # keep track of changes
      t.column :created_on,  :datetime 
    end

  end

  def self.down
    drop_table :comments
  end
end
