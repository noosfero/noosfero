class ProfileCategorization < ApplicationRecord
  self.table_name = :categories_profiles
  belongs_to :profile
  belongs_to :category
  belongs_to :region, :foreign_key => 'category_id'

  extend Categorization

  class << self
    alias :add_category_to_profile :add_category_to_object
    def object_id_column
      :profile_id
    end
  end

  def self.remove_region(profile)
    if profile.old_region_id
      ids = Region.find(profile.old_region_id).hierarchy.map(&:id)
      self.delete_all(:profile_id => profile.id, :category_id => ids)
    end
  end

end
