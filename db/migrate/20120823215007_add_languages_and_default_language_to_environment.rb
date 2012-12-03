class AddLanguagesAndDefaultLanguageToEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :languages, :string
    add_column :environments, :default_language, :string
  end

  def self.down
    remove_column :environments, :languages
    remove_column :environments, :default_language
  end
end
