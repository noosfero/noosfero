class EnablePeopleBlockPlugin < ActiveRecord::Migration[5.1]
  def up
    Environment.all.each do |env|
      env.enabled_plugins << 'PeopleBlockPlugin'
      env.enabled_plugins.uniq!
      env.save!
    end
  end

  def down
    Environment.all.each do |env|
      env.enabled_plugins.delete_if {|i| i== 'PeopleBlockPlugin'}
      env.save!
    end
  end
end
