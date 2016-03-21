class ReactivatePluginAfterRename < ActiveRecord::Migration
  def up
    script_path = Rails.root.join('script').to_s
    system(script_path + '/noosfero-plugins disable environment_notification')
    system(script_path + '/noosfero-plugins enable admin_notifications')

    system("rake db:migrate")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
