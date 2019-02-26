class RemoveSubmissionsWithoutForm < ActiveRecord::Migration[5.1]
  def self.up
    CustomFormsPlugin::Submission.find_each do |submission|
      submission.destroy if submission.form.nil?
    end
  end

  def self.down
    say "This migration is irreversible."
  end
end
