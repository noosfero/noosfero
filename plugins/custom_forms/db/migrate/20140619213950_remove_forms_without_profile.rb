class RemoveFormsWithoutProfile < ActiveRecord::Migration[5.1]
  def self.up
    CustomFormsPlugin::Form.find_each do |form|
      form.destroy if form.profile.nil?
    end
  end

  def self.down
    say "This migration is irreversible."
  end
end
