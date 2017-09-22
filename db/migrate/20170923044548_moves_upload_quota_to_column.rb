class MovesUploadQuotaToColumn < ActiveRecord::Migration
  def up
    add_column :profiles, :upload_quota, :string
    add_column :profiles, :disk_usage, :float
    add_column :kinds, :upload_quota, :string

    ['profiles', 'kinds'].each do |table_name|
      execute("UPDATE #{table_name} "\
              "SET upload_quota = metadata->>'quota' "\
              "WHERE (metadata->>'quota') IS NOT NULL")
    end
  end

  def down
    remove_column :profiles, :upload_quota
    remove_column :profiles, :disk_usage
    remove_column :kinds, :upload_quota
  end
end
