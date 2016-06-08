require_dependency 'person'

class Person
  attr_accessible :interest_list

  acts_as_taggable_on :interests
  N_('Fields of interest')
end
