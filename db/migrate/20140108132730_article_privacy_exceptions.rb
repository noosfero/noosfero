class ArticlePrivacyExceptions < ActiveRecord::Migration
  def self.up
    create_table :article_privacy_exceptions, :id => false do |t|
      t.integer :article_id
      t.integer :person_id
    end
  end

  def self.down
    drop_table :article_privacy_exceptions
  end
end
