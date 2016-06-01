class EnvironmentExternalEnvironments < ActiveRecord::Migration
  def self.up
    create_table :environment_external_environments do |t|
      t.references :environment, index: true
      t.references :external_environment, index: true
    end
  end

  def self.down
    drop_table :environment_external_environments
  end
end
