class AddAcronymAndAbbreviationToCategory < ActiveRecord::Migration
  def self.up
    add_column :categories, :acronym, :string
    add_column :categories, :abbreviation, :string
  end

  def self.down
    remove_column :categories, :abbreviation
    remove_column :categories, :acronym
  end
end
