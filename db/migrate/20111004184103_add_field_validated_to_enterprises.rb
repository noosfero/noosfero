class AddFieldValidatedToEnterprises < ActiveRecord::Migration
  def self.up
    add_column :profiles, :validated, :boolean, :default => true
  end

  def self.down
    add_column :profiles, :validated
  end
end
