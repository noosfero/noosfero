class AddJsonbToEnvironment < ActiveRecord::Migration[4.2]
  def change
    if !column_exists?(:environments, :metadata)
      add_column :environments, :metadata, :jsonb, default: {}
      add_index  :environments, :metadata, using: :gin
    end
  end
end
