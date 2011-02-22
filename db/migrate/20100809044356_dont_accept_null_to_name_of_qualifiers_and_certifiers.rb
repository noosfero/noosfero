class DontAcceptNullToNameOfQualifiersAndCertifiers < ActiveRecord::Migration
  def self.up
    change_table :certifiers do |t|
      t.change :name, :string, :null => false
    end
    change_table :qualifiers do |t|
      t.change :name, :string, :null => false
    end
  end

  def self.down
    change_table :certifiers do |t|
      t.change :name, :string, :null => true
    end
    change_table :qualifiers do |t|
      t.change :name, :string, :null => true
    end
  end
end
