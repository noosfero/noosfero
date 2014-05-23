class CommentGroupPlugin < Noosfero::Plugin

  def self.plugin_name
    "Comment Group"
  end

  def self.plugin_description
    _("A plugin that display comment groups.")
  end

  def unavailable_comments(scope)
    scope.without_group
  end

  def comment_form_extra_contents(args)
    comment = args[:comment]
    group_id = comment.group_id || args[:group_id]
    proc {
      hidden_field_tag('comment[group_id]', group_id) if group_id
    }
  end

  def js_files
    'comment_group_macro.js'
  end

  def stylesheet?
    true
  end


end

require_dependency 'comment_group_plugin/macros/allow_comment'
