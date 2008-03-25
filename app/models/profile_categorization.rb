class ProfileCategorization < ActiveRecord::Base
  set_table_name :categories_profiles
  belongs_to :profile
  belongs_to :category
end
