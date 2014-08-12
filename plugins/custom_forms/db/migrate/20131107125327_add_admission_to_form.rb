class AddAdmissionToForm < ActiveRecord::Migration
  def self.up
    change_table :custom_forms_plugin_forms do |t|
      t.boolean :for_admission, :default => false
    end 

    execute('update custom_forms_plugin_forms set for_admission = (1<0)')
  end

  def self.down
    change_table :custom_forms_plugin_forms do |t|
      t.remove :for_admission
    end 
  end
end
