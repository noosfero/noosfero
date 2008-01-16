class AddDesignSupport < ActiveRecord::Migration
  def self.up

    create_table :boxes do |t|
      t.column :owner_type, :string
      t.column :owner_id,   :integer

      # acts_as_list
      t.column :position, :integer
    end

    create_table :blocks do |t|
      t.column :title,    :string
      t.column :box_id,   :integer
      t.column :type,     :string
      t.column :settings,     :text

      # acts_as_list
      t.column :position, :integer
    end

  end

  def self.down
    drop_table :boxes
    drop_table :blocks
  end

end
