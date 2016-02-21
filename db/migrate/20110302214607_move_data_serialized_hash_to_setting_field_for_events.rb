class MoveDataSerializedHashToSettingFieldForEvents < ActiveRecord::Migration
  def self.up
    select_all("SELECT id FROM articles WHERE type = 'Event' AND body LIKE '%:link:%'").each do |data|
      article = Event.find(data['id'])
      body = ''
      begin
        body = YAML.load(article.body)
      rescue
        # do nothing
        next
      end
      if body.kind_of?(Hash)
        settings = article.setting.merge(body)
        body = ApplicationRecord.sanitize_sql_for_assignment(:body => settings[:description])
        update("UPDATE articles set %s WHERE id = %d" % [body, article.id])
        setting = ApplicationRecord.sanitize_sql_for_assignment(:setting => settings.to_yaml)
        update("UPDATE articles set %s WHERE id = %d" % [setting, article.id])
      end
    end
  end

  def self.down
    say "Nothing to undo"
  end
end
