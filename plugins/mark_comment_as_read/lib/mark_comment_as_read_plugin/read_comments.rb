class MarkCommentAsReadPlugin::ReadComments < ActiveRecord::Base
  self.table_name = 'mark_comment_as_read_plugin'
  belongs_to :comment
  belongs_to :person

  validates_presence_of :comment, :person
end
