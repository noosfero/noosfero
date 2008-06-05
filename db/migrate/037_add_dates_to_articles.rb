class AddDatesToArticles < ActiveRecord::Migration

  def self.each_table
    [ :articles, :article_versions ].each do |table|
      yield(table)
    end
  end

  def self.up
    each_table do |table|
      add_column table, :start_date, :type => :date
      add_column table, :end_date, :type => :date
    end
  end

  def self.down
    each_table do |table|
      remove_column table, :start_date
      remove_column table, :end_date
    end
  end
end
