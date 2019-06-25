class AddOwnerToImage < ActiveRecord::Migration[4.2]
  def change
    add_reference :images, :owner, polymorphic: true, index: true
  end
end
