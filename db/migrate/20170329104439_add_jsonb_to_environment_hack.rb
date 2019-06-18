class AddJsonbToEnvironmentHack < ActiveRecord::Migration[4.2]
  def change
      add_column :environments, :metadata, :jsonb, :default => {}
      add_index  :environments, :metadata, using: :gin
  end
end
