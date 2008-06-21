class ProfileCategorization < ActiveRecord::Base
  set_table_name :categories_profiles
  belongs_to :profile
  belongs_to :category

  after_create :associate_with_entire_hierarchy
  def associate_with_entire_hierarchy
    return if virtual

    c = category.parent
    while !c.nil? && !self.class.find(:first, :conditions => {:profile_id => profile, :category_id => c}) 
      self.class.create!(:profile => profile, :category => c, :virtual => true)
      c = c.parent
    end
  end

  def self.remove_all_for(profile)
    self.delete_all(:profile_id => profile.id)
  end

end
