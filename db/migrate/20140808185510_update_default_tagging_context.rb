class UpdateDefaultTaggingContext < ActiveRecord::Migration

  def self.up
    ActsAsTaggableOn::Tagging.where(:taggable_type => Article, :context => nil).update_all(:context => 'tags')
  end

  def self.down
    ActsAsTaggableOn::Tagging.where(:taggable_type => Article, :context => 'tags').update_all(:context => nil)
  end

end
