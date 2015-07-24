class ChangeArticleDateToDatetime < ActiveRecord::Migration

  def up
    change_table :articles do |t|
      t.change :start_date, :datetime
      t.change :end_date, :datetime
    end

    change_table :article_versions do |t|
      t.change :start_date, :datetime
      t.change :end_date, :datetime
    end
  end

  def down
    change_table :articles do |t|
      t.change :start_date, :date
      t.change :end_date, :date
    end

    change_table :article_versions do |t|
      t.change :start_date, :date
      t.change :end_date, :date
    end
  end

end
