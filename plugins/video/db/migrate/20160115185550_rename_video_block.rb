class RenameVideoBlock < ActiveRecord::Migration
  def up
    execute("UPDATE blocks SET type = 'VideoPlugin::VideoBlock' WHERE type = 'VideoBlock'")
  end

  def down
    say "this migration can't be reverted"
  end
end

