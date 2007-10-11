# Region is a special type of category that is related to geographical issues. 
class Region < Category
  has_and_belongs_to_many :validators, :class_name => Organization.name, :join_table => :region_validators
end
