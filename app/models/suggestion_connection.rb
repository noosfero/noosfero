class SuggestionConnection < ActiveRecord::Base
  attr_accessible :suggestion, :suggestion_id, :connection_type, :connection_id

  belongs_to :suggestion, :class_name => 'ProfileSuggestion', :foreign_key => 'suggestion_id'
  belongs_to :connection, :polymorphic => true
end
