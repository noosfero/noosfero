class AddSettingsToComments < ActiveRecord::Migration
  def change
    add_column :comments, :settings, :text
  end
end
