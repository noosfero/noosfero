class FinishEnterpriseActivationForEnabledEnterprises < ActiveRecord::Migration
  def self.up
    EnterpriseActivation.find_each do |enterprise_activation|
      enterprise = enterprise_activation.enterprise
      next unless enterprise.present? && enterprise.enabled
      enterprise_activation.update_attribute :status, Task::Status::FINISHED
    end
  end

  def self.down
    say "this migration can't be reverted"
  end
end
