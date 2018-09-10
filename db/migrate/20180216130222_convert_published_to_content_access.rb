class ConvertPublishedToContentAccess < ActiveRecord::Migration
  def up
    Article.where('published = ?', false)
      .update_all(access: Entitlement::Levels.levels[:self],
                  published: true)

    Article.joins("inner join profiles on articles.profile_id = profiles.id ").
      where('profiles.public_profile = ? and articles.access < ?',
                  false, Entitlement::Levels.levels[:related])
      .update_all(access: Entitlement::Levels.levels[:related],
                  published: true)
  end

  def down
    Article.where('access = ?', Entitlement::Levels.levels[:self])
      .update_all(published: false)
  end
end
