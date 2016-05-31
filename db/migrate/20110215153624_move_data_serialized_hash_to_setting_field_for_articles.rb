class MoveDataSerializedHashToSettingFieldForArticles < ActiveRecord::Migration
  def self.up
    select_all("SELECT id FROM tasks WHERE type = 'ApproveArticle' AND status = 1").each do |data|
      article = Task.find(data['id']).article
      next unless article.kind_of?(Event)
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
