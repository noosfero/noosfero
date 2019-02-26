class MarkCommentAsReadPlugin::ReadComments < ApplicationRecord
  self.table_name = 'mark_comment_as_read_plugin'
  belongs_to :comment, optional: true
  belongs_to :person, optional: true

  validates_presence_of :comment, :person
end
