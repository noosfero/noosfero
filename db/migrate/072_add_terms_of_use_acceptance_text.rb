class AddTermsOfUseAcceptanceText < ActiveRecord::Migration
  def self.up
    add_column :environments, :terms_of_use_acceptance_text, :text
  end

  def self.down
    remove_column :environments, :terms_of_use_acceptance_text
  end
end
