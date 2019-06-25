class RemoveSignUpBlacklistMetatadaOfEnvironment < ActiveRecord::Migration[4.2]
  def change
    Environment.all.each do |environment|
      environment.metadata.delete('signup_blacklist')
      environment.save
    end
  end
end
