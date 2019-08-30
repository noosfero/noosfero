class AddJsonbFields < ActiveRecord::Migration[4.2]
  def change
    %w[profiles articles tasks blocks users].each do |table|
      add_column table, :metadata, :jsonb, default: {}
      add_index  table, :metadata, using: :gin
    end
  end
end
