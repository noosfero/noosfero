class BootstrapProfileSuggestions < ActiveRecord::Migration
  def up
    ProfileSuggestion.generate_all_profile_suggestions
  end

  def down
    ProfileSuggestion.delete_all
  end
end
