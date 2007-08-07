#An enterprise is a kind of organization. According to the system concept, only enterprises can offer products/services and ahave to be validated by an validation entity
class Enterprise < Organization
  belongs_to :validation_entity, :class_name => 'organization', :foreign_key => 'validation_entity_id'
end
