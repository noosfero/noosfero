class AddJsonbToEnvironment < ActiveRecord::Migration
  def change
      add_column :environments, :metadata, :jsonb, :default => {}
      add_index  :environments, :metadata, using: :gin
  end
end
