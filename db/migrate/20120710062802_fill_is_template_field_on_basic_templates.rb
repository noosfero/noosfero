class FillIsTemplateFieldOnBasicTemplates < ActiveRecord::Migration
  def self.up
    update("update profiles set is_template = 't' where identifier like '%_template'")
  end

  def self.down
    say('This migration can\'t be reverted.')
  end
end
