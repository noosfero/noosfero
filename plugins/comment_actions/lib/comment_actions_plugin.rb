class CommentActionsPlugin < Noosfero::Plugin

  def self.plugin_name
    "Comment Actions"
  end

  def self.plugin_description
    _("A comment action menu plugin!")
  end

  def comment_actions(comment)
    [
      {
	s_('Mark as read') => {
	  'href' => '#', 
	  'onclick' => 'alert(\'Click on Mark as read action!\')'
	}
      } 
    ]
  end

end
