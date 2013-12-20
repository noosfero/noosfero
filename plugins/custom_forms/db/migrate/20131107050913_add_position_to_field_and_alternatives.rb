class AddPositionToFieldAndAlternatives < ActiveRecord::Migration
  def self.up
    change_table :custom_forms_plugin_alternatives do |t|
      t.integer :position, :default => 0
    end

    CustomFormsPlugin::Field.find_each do |f|
      f.position = f.id
      f.save!
    end

    CustomFormsPlugin::Alternative.find_each do |f|
      f.position = f.id
      f.save!
    end
  end

  def self.down
    change_table :custom_forms_plugin_alternatives do |t|
      t.remove :position
    end
  end
end
