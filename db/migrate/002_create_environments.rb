class CreateEnvironments < ActiveRecord::Migration
  def self.up
    create_table :environments do |t|
      t.column :name,       :string
      t.column :is_default, :boolean
      t.column :settings,   :text
      t.column :design_data, :text
    end
    Environment.create!(:name => 'Default Environment', :is_default => true)
  end

  def self.down
    drop_table :environments
  end
end
