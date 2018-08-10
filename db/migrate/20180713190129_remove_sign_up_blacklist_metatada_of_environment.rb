class RemoveSignUpBlacklistMetatadaOfEnvironment < ActiveRecord::Migration
  def change
    Environment.all.each do |environment|
      environment.metadata.delete('signup_blacklist')
      environment.save
    end
  end
end
