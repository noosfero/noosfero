class AddPolymorphismOnComment < ActiveRecord::Migration
  def self.up
    rename_column :comments, :article_id, :source_id
    add_column :comments, :source_type, :string
    execute("update comments set source_type = 'Article'")
  end

  def self.down
    remove_column :comments, :source_type
    rename_column :comments, :source_id, :article_id
  end
end
