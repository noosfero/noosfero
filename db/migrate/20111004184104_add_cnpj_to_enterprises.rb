class AddCnpjToEnterprises < ActiveRecord::Migration
  def self.up
    add_column :profiles, :cnpj, :string
  end

  def self.down
    remove_column :profiles, :cnpj
  end
end
