class CreateSuggestionConnections < ActiveRecord::Migration
  def up
    create_table :suggestion_connections do |t|
      t.references :suggestion, :null => false
      t.references :connection, :polymorphic => true, :null => false
    end
  end

  def down
    drop_table :suggestion_connections
  end
end
