class ChangeTaskEndDateFromDateToDateTime < ActiveRecord::Migration

  def up
      change_column :tasks, :end_date, :datetime
  end

  def down
    change_column :tasks, :end_date, :date
  end
end
