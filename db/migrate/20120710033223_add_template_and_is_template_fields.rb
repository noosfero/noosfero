class AddTemplateAndIsTemplateFields < ActiveRecord::Migration
  def self.up
    add_column :profiles, :is_template, :boolean, :default => false
    add_column :profiles, :template_id, :integer
  end

  def self.down
    remove_column :profiles, :is_template
    remove_column :profiles, :template_id
  end
end
