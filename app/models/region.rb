# Region is a special type of category that is related to geographical issues.
class Region < Category

  attr_accessible :name

  has_and_belongs_to_many :validators, :class_name => 'Organization', :join_table => :region_validators

  require_dependency 'enterprise' # enterprises can also be validators

  def has_validator?
    validators.count > 0
  end

  scope :with_validators, -> {
    select('DISTINCT ON (categories.id) *')
      .joins('INNER JOIN region_validators on (region_validators.region_id = categories.id)')
  }

end

require_dependency 'city'
require_dependency 'state'
