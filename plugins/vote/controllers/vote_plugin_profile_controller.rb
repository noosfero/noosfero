class VotePluginProfileController < ProfileController

  before_filter :login_required, :only => [:vote]

  def vote
    model = params[:model].to_sym
    vote = params[:vote].to_i
    settings = Noosfero::Plugin::Settings.new(environment, VotePlugin)
    model_settings = settings.get_setting("enable_vote_#{model}")

    unless model_settings && model_settings.include?(vote)
      render_access_denied
      return
    end

    object = target(model)
    vote_target(object, vote)

    render :update do |page|
      model_settings.each do |v|
        page.replace "vote_#{model}_#{params[:id]}_#{v}", instance_eval(&controller.vote_partial(object, v==1, false))
      end
    end
  end

  include VotePluginHelper

  def reload_vote
    model = params[:model].to_sym
    vote = params[:vote].to_i
    object = target(model)

    render :update do |page|
      page.replace "vote_#{model}_#{params[:id]}_#{vote}", instance_eval(&controller.vote_partial(object, vote==1, true))
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
