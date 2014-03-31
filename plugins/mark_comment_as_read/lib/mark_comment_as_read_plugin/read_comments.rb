class MarkCommentAsReadPlugin::ReadComments < Noosfero::Plugin::ActiveRecord
  set_table_name 'mark_comment_as_read_plugin'
  belongs_to :comment
  belongs_to :person

  validates_presence_of :comment, :person
end
