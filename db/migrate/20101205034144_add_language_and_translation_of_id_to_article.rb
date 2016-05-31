class AddLanguageAndTranslationOfIdToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :translation_of_id, :integer
    add_column :articles, :language, :string

    add_column :article_versions, :translation_of_id, :integer
    add_column :article_versions, :language, :string

    add_index  :articles, :translation_of_id

    select_all("select id, setting from articles where type = 'Blog'").each do |blog|
      settings = YAML.load(blog['setting'] || {}.to_yaml)
      settings[:display_posts_in_current_language] = true
      assignments = ApplicationRecord.sanitize_sql_for_assignment(:setting => settings.to_yaml)
      update("update articles set %s where id = %d" % [assignments, blog['id']])
    end

  end

  def self.down
    remove_index :articles, :translation_of_id

    remove_column :article_versions, :translation_of_id
    remove_column :article_versions, :language

    remove_column :articles, :language
    remove_column :articles, :translation_of_id
  end
end
