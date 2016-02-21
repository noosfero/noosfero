class SetOwnerEnvironmentToEnterprisesEnvironment < ActiveRecord::Migration
  def self.up
    CreateEnterprise.where(status: 3).each do |t|
      if(Enterprise.find_by(identifier: t.data[:identifier]))
        update("UPDATE profiles SET environment_id = '%s' WHERE identifier = '%s'" %
              [Person.find(t.requestor_id).environment.id, t.data[:identifier]])
      end
    end
  end

  def self.down
    say "this migration can't be reverted"
  end
end
