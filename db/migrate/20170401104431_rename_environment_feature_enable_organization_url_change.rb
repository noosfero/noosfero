class RenameEnvironmentFeatureEnableOrganizationUrlChange < ActiveRecord::Migration
  $old_feature_name = :enable_organization_url_change_enabled
  $new_feature_name = :enable_profile_url_change_enabled
  def up
    Environment.find_each do |env|
      if env.settings.has_key? $old_feature_name
        value = env.settings[$old_feature_name]
        env.settings[$new_feature_name] = value
        env.settings.delete($old_feature_name)
        env.save!
      end
    end
  end

  def down
    say "This migration can't be reverted!"
  end
end
