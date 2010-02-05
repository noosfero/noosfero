class Environment < ActiveRecord::Base
  set_table_name 'environments'
  serialize :settings, Hash
end

class SetVisibleToProfiles < ActiveRecord::Migration
  def self.up
    templates = []
    Environment.all.each do |e|
      templates << e.settings[:person_template_id]
      templates << e.settings[:enterprise_template_id]
      templates << e.settings[:inactive_enterprise_template_id]
      templates << e.settings[:community_template_id]
    end
    execute "update profiles set visible=(1=1) where id NOT IN (#{templates.compact.join(',')})"
  end

  def self.down
    say("Nothing to undo (cannot recover the data)")
  end
end
