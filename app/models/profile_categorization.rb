class ProfileCategorization < ApplicationRecord
  self.table_name = :categories_profiles
  belongs_to :profile
  belongs_to :category

  extend Categorization

  class << self
    alias :add_category_to_profile :add_category_to_object
    def object_id_column
      :profile_id
    end
  end

  def self.remove_region(profile)
    region = profile.categories.where(type: [Region, State, City].map(&:name)).first
    if region
      ids = region.hierarchy.map(&:id)
      self.delete_all(:profile_id => profile.id, :category_id => ids)
    end
  end

end
