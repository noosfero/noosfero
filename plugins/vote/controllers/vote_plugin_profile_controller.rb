class VotePluginProfileController < ProfileController
  helper VotePluginHelper

  before_action :login_required, :only => [:vote]

  def vote
    @model = params[:model].to_sym
    @model_id = params[:id]

    vote = params[:vote].to_i
    settings = Noosfero::Plugin::Settings.new(environment, VotePlugin)
    @model_settings = settings.send("enable_vote_#{@model}")

    unless @model_settings && @model_settings.include?(vote)
      render_access_denied
      return
    end

    @object = target(@model)
    vote_target(@object, vote)

    respond_to do |format|
      format.js
    end
  end

  def reload_vote
    @model = params[:model].to_sym
    @model_id = params[:id]
    @vote = params[:vote].to_i
    @object = target(@model)

    respond_to do |format|
      format.js
    end
  end

  protected

  def target(model)
    case model
      when :article
        profile.articles.find(params[:id])
      when :comment
        profile.comments_received.find(params[:id])
    end
  end

  def vote_target(object, vote)
    old_vote = user.votes.for_voteable(object).first
    user.votes.for_voteable(object).each { |v| v.destroy }
    if old_vote.nil? || old_vote.vote != vote
      user.vote(object, vote)
    end
  end

end
