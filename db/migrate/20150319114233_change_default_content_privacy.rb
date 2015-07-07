class ChangeDefaultContentPrivacy < ActiveRecord::Migration
  def up
    update_sql('UPDATE articles SET published = (1>2), show_to_followers = (1=1)
      FROM profiles WHERE articles.profile_id = profiles.id AND
      NOT profiles.public_profile AND articles.published = (1=1)')

    Block.select('blocks.*').joins("INNER JOIN boxes ON blocks.box_id = boxes.id
      INNER JOIN profiles ON boxes.owner_id = profiles.id AND boxes.owner_type = 'Profile'").
      where("NOT profiles.public_profile AND blocks.type != 'MainBlock'").find_each do |block|
      block.display_user = 'followers'
      block.save
    end
    change_column :articles, :show_to_followers, :boolean, :default => true
  end

  def down
    say "this migration can't be reverted"
  end
end
