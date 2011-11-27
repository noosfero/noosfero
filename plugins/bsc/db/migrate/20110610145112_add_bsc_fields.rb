class AddBscFields < ActiveRecord::Migration
  def self.up
    add_column :profiles, :company_name, :string
  end

  def self.down
    remove_column :profiles, :company_name
  end
end
