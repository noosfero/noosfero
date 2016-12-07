class AddOwnerToImage < ActiveRecord::Migration
  def change
    add_reference :images, :owner, polymorphic: true, index: true
  end
end
