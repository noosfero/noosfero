class StripHtmlFromTagNames < ActiveRecord::Migration
  def self.up
    Tag.where("name LIKE '%<%' OR name LIKE '%>%'").find_each do |tag|
      tag.name = tag.name.gsub(/[<>]/, '')
      tag.save
    end
  end

  def self.down
    say "WARNING: cannot undo this migration"
  end
end
