class SetActivationCodeToNilIfAlreadyActivated < ActiveRecord::Migration
  def self.up
    update("UPDATE users SET activation_code = null WHERE activated_at IS NOT NULL")
  end

  def self.down
    say('Can not be reverted.')
  end
end
