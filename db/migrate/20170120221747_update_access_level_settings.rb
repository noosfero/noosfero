class UpdateAccessLevelSettings < ActiveRecord::Migration
  def up
    valid_levels = {
      'visitors' => 0,
      'users' => 1, 'usuários' => 1, 'usuarios' => 1,
      'related' => 2,
      'self' => 3,
    }
    
    select_all("SELECT id, data FROM profiles WHERE type='Person' AND data LIKE '%:wall_access:%'").each do |person|
      data = YAML.load(person['data'] || {}.to_yaml)
      data[:wall_access] = valid_levels[data[:wall_access]] || valid_levels['self']
      update("UPDATE profiles SET data=#{connection.quote(data.to_yaml)} WHERE id=#{person['id']}")
    end

    select_all("SELECT id, setting FROM articles WHERE type='Forum' AND setting LIKE '%:topic_creation:%'").each do |forum|
      data = YAML.load(forum['setting'] || {}.to_yaml)
      data[:topic_creation] = valid_levels[data[:topic_creation]] || valid_levels['self']
      update("UPDATE articles SET setting=#{connection.quote(data.to_yaml)} WHERE id=#{forum['id']}")
    end
  end

  def down
    say "this migration can't be reverted"
  end
end
