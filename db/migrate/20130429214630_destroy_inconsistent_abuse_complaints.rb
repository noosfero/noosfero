class DestroyInconsistentAbuseComplaints < ActiveRecord::Migration
  def self.up
    AbuseComplaint.all.each do |ac|
      if ac.reported.nil?
        ac.destroy
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
