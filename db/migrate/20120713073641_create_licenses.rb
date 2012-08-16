class CreateLicenses < ActiveRecord::Migration
  def self.up
    create_table :licenses do |t|
      t.string      :name, :null => false
      t.string      :slug, :null => false
      t.string      :url
      t.references  :environment, :null => false
    end
  end

  def self.down
    drop_table :licenses
  end
end
