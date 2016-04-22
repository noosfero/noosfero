class RenameImagesPathOnTrackedActions < ActiveRecord::Migration

  def self.up
    select_all("SELECT id, verb, params FROM action_tracker WHERE verb IN ('new_friendship', 'join_community', 'leave_community')").each do |tracker|
      if tracker['verb'] == 'new_friendship'
        param_name = 'friend_profile_custom_icon'
      else
        param_name = 'resource_profile_custom_icon'
      end

      params = YAML.load(tracker['params'])
      paths = []
      params[param_name].each do |image_path|
        paths << self.rename_path(image_path) unless image_path.nil?
      end
      params[param_name] = paths

      execute(ApplicationRecord.sanitize_sql(["UPDATE action_tracker SET params = ? WHERE id  = ?", params.to_yaml, tracker['id']]))
    end
  end

  def self.down
    say('Nothing to undo')
  end

  class << self
    def rename_path(old_path)
      if old_path =~ /^\/images\/0/
        old_path.gsub(/^\/images\//, "/image_uploads/")
      else
        old_path
      end
    end
  end

end
