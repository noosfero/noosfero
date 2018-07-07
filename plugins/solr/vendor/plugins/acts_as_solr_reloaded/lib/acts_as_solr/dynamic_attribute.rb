class DynamicAttribute < ApplicationRecord
  belongs_to :dynamicable, polymorphic:  true, optional: true
end
