class AddDateFormatToEnvironment < ActiveRecord::Migration
  def up
    add_column :environments, :date_format, :string, :default => 'month_name_with_year'
  end

  def down
    remove_column :environments, :date_format
  end
end
