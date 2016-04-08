require 'ext/environment'
require 'ext/comment'

class CommentClassificationPlugin < Noosfero::Plugin

  def self.plugin_name
    "Comment Classification"
  end

  def self.plugin_description
    _("A plugin that allow classification of comments.")
  end

#TODO Each organization can add its own status and labels
#  def control_panel_buttons
#    if context.profile.organization?
#      { :title => _('Manage comment classification'), :icon => 'comment_classification', :url => {:controller => 'comment_classification_plugin_myprofile'} }
#    end
#  end

  def comment_form_extra_contents(args)
    comment = args[:comment]
    proc {
      render :file => 'comment/comments_labels_select', :locals => {:comment => comment }
    }
  end

  def comment_extra_contents(args)
    comment = args[:comment]
    proc {
      render :file => 'comment/comment_extra', :locals => {:comment => comment}
    }
  end

  def process_extra_comment_params(args)
    comment = Comment.find args[0]
    label_id = args[1][:comment_label_id]
    if label_id.blank?
      if !CommentClassificationPlugin::CommentLabelUser.find_by(comment_id: comment.id).nil?
        CommentClassificationPlugin::CommentLabelUser.find_by(comment_id: comment.id).destroy
      end
    else
      label = CommentClassificationPlugin::Label.find label_id
      relation = CommentClassificationPlugin::CommentLabelUser.new(:profile => comment.author, :comment => comment, :label => label )
      relation.save
    end
  end

  def stylesheet?
    true
  end

end
