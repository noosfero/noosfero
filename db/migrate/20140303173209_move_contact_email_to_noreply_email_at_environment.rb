class MoveContactEmailToNoreplyEmailAtEnvironment < ActiveRecord::Migration
  def self.up
    add_column :environments, :noreply_email, :string
    Environment.reset_column_information

    Environment.find_each do |environment|
      environment.noreply_email = environment.contact_email
      environment.contact_email = nil
      environment.save!
    end
  end

  def self.down
    say "this migration can't be reverted"
  end
end
