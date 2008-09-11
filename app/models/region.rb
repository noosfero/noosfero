# Region is a special type of category that is related to geographical issues. 
class Region < Category
  has_and_belongs_to_many :validators, :class_name => 'Organization', :join_table => :region_validators

  require_dependency 'enterprise' # enterprises can also be validators

  # searches for organizations that could become validators for this region.
  # <tt>search</tt> is passed as is to ferret's find_by_contents on Organizatio
  # find_by_contents on Organization class.
  def search_possible_validators(search)
    Organization.find_by_contents(search).reject {|item| self.validator_ids.include?(item.id) }
  end

  def has_validator?
    validators.count > 0
  end
  
end
