class SetTargetForEnterpriseActivation < ActiveRecord::Migration
  def self.up
    EnterpriseActivation.find_each do |enterprise_activation|
      enterprise_activation.target = enterprise_activation.enterprise
      enterprise_activation.data.delete :enterprise_id
      enterprise_activation.save
    end
  end

  def self.down
    say "this migration can't be reverted"
  end
end
