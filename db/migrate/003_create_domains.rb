class CreateDomains < ActiveRecord::Migration
  def self.up
    create_table :domains do |t|
      t.column :name, :string
      t.column :owner_type, :string
      t.column :owner_id, :integer
    end
  end

  def self.down
    drop_table :domains
  end
end
