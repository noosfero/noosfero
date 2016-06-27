require_dependency 'person'

class Person
  attr_accessible :tag_list

  acts_as_taggable_on :tags
  N_('Fields of interest')
end
