class CommentParagraphPlugin::SelectAll < Noosfero::Plugin::Macro
  def self.configuration
    { params: [],
      skip_dialog: true,
      generator: 'makeAllCommentable();',
      js_files: 'macro/allow_comment.js',
      title: _('Select/Deselect all sections as commentable'),
      icon_path: '/designs/icons/tango/Tango/16x16/apps/internet-group-chat.png',
      css_files: 'macro/allow_comment.css' }
  end
end
