class FixTagsCaseDifferences < ActiveRecord::Migration
  def up
    tags = ActsAsTaggableOn::Tag.joins('LEFT JOIN tags as b on LOWER(tags.name) = b.name').where('b.id is null')
    tags.find_each do |tag|
      unless ActsAsTaggableOn::Tag.exists?(:name => tag.name.mb_chars.downcase)
        ActsAsTaggableOn::Tag.create(:name => tag.name.mb_chars.downcase)
      end
    end

    execute("UPDATE taggings SET tag_id = new.id FROM taggings AS t INNER JOIN tags AS old ON t.tag_id = old.id INNER JOIN tags AS new ON LOWER(old.name) = new.name WHERE old.id != new.id AND taggings.id = t.id")

    execute("UPDATE tags SET taggings_count = (SELECT COUNT(*) FROM taggings WHERE taggings.tag_id = tags.id)")
    execute("DELETE FROM tags WHERE taggings_count = 0")
  end

  def down
    say 'This migration is irreversible.'
  end
end
