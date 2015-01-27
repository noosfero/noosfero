class ChangeAddressTypeToTextInExternalFeed < ActiveRecord::Migration
  def up
    change_column :external_feeds, :address, :text
  end

  def down
    change_column :external_feeds, :address, :string
  end
end
