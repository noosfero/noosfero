class CreateEnterpriseInfos < ActiveRecord::Migration
  def self.up
    create_table :enterprise_infos do |t|
      t.column :approval_status,   :string, :default => 'not evaluated'
      t.column :approval_comments, :text
      t.column :enterprise_id,     :integer
    end
  end

  def self.down
    drop_table :enterprise_infos
  end
end
