# Region is a special type of category that is related to geographical issues. 
class Region < Category
  has_and_belongs_to_many :validators, :class_name => 'Organization', :join_table => :region_validators

  require_dependency 'enterprise' # enterprises can also be validators

  # searches for organizations that could become validators for this region.
  # <tt>search</tt> is passed as is to find_by_contents on Organization.
  def search_possible_validators(search)
    Organization.find_by_contents(search)[:results].reject {|item| self.validator_ids.include?(item.id) }
  end

  def has_validator?
    validators.count > 0
  end

  def self.with_validators
    Region.find(:all, :joins => 'INNER JOIN region_validators on (region_validators.region_id = categories.id)', :select => "distinct #{table_name}.*")
  end
  
end

require_dependency 'city'
require_dependency 'state'
