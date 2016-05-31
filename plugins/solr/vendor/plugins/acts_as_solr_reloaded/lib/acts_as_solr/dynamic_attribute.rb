class DynamicAttribute < ApplicationRecord
  belongs_to :dynamicable, :polymorphic => true
end
