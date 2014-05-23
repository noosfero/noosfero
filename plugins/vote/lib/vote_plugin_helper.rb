module VotePluginHelper

  def vote_partial(target, like = true, load_voters=false)
    vote = like ? 1 : -1
    like_action = like ? 'like' : 'dislike'
    type = target.kind_of?(Article) ? 'article' : target.kind_of?(Comment) ? 'comment' : nil

    proc do
      settings = Noosfero::Plugin::Settings.new(environment, VotePlugin)

      if settings.get_setting("enable_vote_#{type}").include?(vote)

        voters = !load_voters ? nil : target.votes.where(:vote => vote).includes(:voter).limit(settings.get_setting('voters_limit')).map(&:voter)
        active = user ? (like ? user.voted_for?(target) : user.voted_against?(target)) : false
        count = like ? target.votes_for : target.votes_against

        render(:partial => 'vote/vote', :locals => {:target => target, :active => active, :action => like_action, :count => count, :voters => voters, :vote => vote, :model => type })
      else
        ""
      end
    end
  end

end
