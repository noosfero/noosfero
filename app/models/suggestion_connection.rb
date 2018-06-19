class SuggestionConnection < ApplicationRecord

  attr_accessible :suggestion, :suggestion_id, :connection_type, :connection_id

  belongs_to :suggestion, class_name: 'ProfileSuggestion', foreign_key: 'suggestion_id', optional: true
  belongs_to :connection, polymorphic: true, optional: true
end
