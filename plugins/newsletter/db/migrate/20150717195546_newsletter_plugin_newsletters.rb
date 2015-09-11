class NewsletterPluginNewsletters < ActiveRecord::Migration
  def up
    create_table :newsletter_plugin_newsletters do |t|
      t.references :environment, :null => false
      t.references :person, :null => false
      t.boolean :enabled, :default => false
      t.string :subject
      t.integer :periodicity, :default => 0
      t.integer :posts_per_blog, :default => 0
      t.integer :image_id
      t.text :footer
      t.text :blog_ids
      t.text :additional_recipients
      t.boolean :moderated
      t.text :unsubscribers
    end
    add_index :newsletter_plugin_newsletters, :environment_id, :uniq => true
  end

  def down
    remove_index :newsletter_plugin_newsletters, :environment_id
    drop_table :newsletter_plugin_newsletters
  end
end
