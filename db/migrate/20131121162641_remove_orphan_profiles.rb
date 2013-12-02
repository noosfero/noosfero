class RemoveOrphanProfiles < ActiveRecord::Migration
  def self.up
    profiles = Profile.joins('LEFT JOIN environments ON profiles.environment_id=environments.id').where('environments.id IS NULL')
    profiles.map(&:destroy)
  end

  def self.down
    say 'This migration can not be reverted.'
  end
end
