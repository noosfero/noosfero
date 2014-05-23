class VotePlugin < Noosfero::Plugin

  def self.plugin_name
    "Vote Plugin"
  end

  def self.plugin_description
    _("Provide buttons to like/dislike a articles and comments.")
  end

  def stylesheet?
    true
  end

  def js_files
    'vote_actions.js'
  end

  def self.enable_vote_article_default_setting
    [-1, 1]
  end

  def self.enable_vote_comment_default_setting
    [-1, 1]
  end

  def self.voters_limit_default_setting
    6
  end

  include VotePluginHelper

  def comment_actions(comment)
    like = vote_partial(comment)
    dislike = vote_partial(comment, false)
    proc do
      [{:link => instance_eval(&dislike), :action_bar => true}, {:link => instance_eval(&like), :action_bar => true}]
    end
  end

  def article_header_extra_contents(article)
    like = vote_partial(article)
    dislike = vote_partial(article, false)
    proc do
      content_tag('div', instance_eval(&dislike) + instance_eval(&like), :class => 'vote-actions')
    end
  end

end
