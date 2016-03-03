class AddDataToMailing < ActiveRecord::Migration
  def change
    add_column :mailings, :data, :text
  end
end
