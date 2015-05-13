class ChangeDefaultContentPrivacy < ActiveRecord::Migration
  def up
    ids = execute("SELECT id from profiles WHERE NOT public_profile")
    profiles_ids = ids.map { |p| p["id"] }
    unless ids.num_tuples.zero?
      execute('UPDATE articles SET published = (1>2), show_to_followers = (1=1)
       FROM articles AS a INNER JOIN profiles ON a.profile_id = profiles.id
        WHERE NOT profiles.public_profile AND articles.id = a.id AND a.published = (1=1)')
      Block.includes(:box).where(
        :boxes => {:owner_type => "Profile", 
          :owner_id => profiles_ids}).where(
            'type != ?', "MainBlock").find_each do |block|
        block.display_user = 'followers'
        block.save
      end
    end
    change_column :articles, :show_to_followers, :boolean, :default => true
  end

  def down
    say "this migration can't be reverted"
  end
end
