module VotePluginHelper
  def vote_partial(target, like = true, load_voters = false)
    vote = like ? 1 : -1

    like_action = like ? "like" : "dislike"
    type = target.kind_of?(Article) ? "article" : target.kind_of?(Comment) ? "comment" : nil
    disable_vote = target.archived? ? true : false

    proc do
      settings = Noosfero::Plugin::Settings.new(environment, VotePlugin)

      if settings.send("enable_vote_#{type}").include?(vote)

        voters = !load_voters ? nil : target.votes.where(vote: vote).includes(:voter).limit(settings.voters_limit).map(&:voter)
        active = user ? (like ? user.voted_for?(target) : user.voted_against?(target)) : false
        count = like ? target.votes_for : target.votes_against

        render(partial: "vote/vote", locals: { target: target, active: active, action: like_action, count: count, voters: voters, vote: vote, model: type, disable_vote: disable_vote })
      else
        ""
      end
    end
  end
end
