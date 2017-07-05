class MailingListPluginMyprofileOrganizationController < MailingListPluginMyprofileController
  def edit
    @collection = profile.members
    super

    if request.post?
      update_watched_contents(profile, params[:watched_contents])
      @profile_settings = Noosfero::Plugin::Settings.new profile, MailingListPlugin, params[:profile_settings]
      @profile_settings.enabled = @profile_settings.enabled == "1"
      @profile_settings.save!
    end
    @contents = prepare_to_token_input(profile.articles.with_plugin_metadata(MailingListPlugin, { watched: true }))
  end

  def search_content
    scope = profile.articles.where("articles.type = 'Blog' OR articles.type = 'Forum'")
    scope = scope.where("NOT(metadata ? 'mailing_list_plugin') OR NOT(metadata -> 'mailing_list_plugin' ? 'watched') OR (metadata #> '{mailing_list_plugin,watched}' = 'false')")
    result = find_by_contents(:articles, profile, scope, params[:q])[:results]
    render :text => prepare_to_token_input(result).to_json
  end

  def subscribe
    @person = profile.members.find(params[:id])
    @group = profile

    if user == @person # Group admin trying to subscribe herself/himself to the mailing list
      @client.subscribe_person_on_group_list(@person, @group)
      session[:notice] = _('%s was subscribed on this mailing list') % @person.name
    elsif MailingListPlugin::AcceptSubscription.ongoing_subscription?(@person, @group) # Group admin approves member's request to subscribe
      ongoing_subscription = MailingListPlugin::AcceptSubscription.ongoing_subscription(@person, @group)
      ongoing_subscription.finish
      session[:notice] = _('%s request to be subscribed on this mailing list was accepted') % @person.name
    elsif !MailingListPlugin::SubscribeMember.ongoing_subscription?(@person, @group) # Group admin trying to subscribe member to the mailing list
      task = MailingListPlugin::SubscribeMember.new(:requestor => user, :target => @person)
      task.metadata['group_id'] = @group.id
      task.save!
      session[:notice] = _('%s was asked to join this mailing list') % @person.name
    else # Group admin already asked member to join the mailing list
      session[:notice] = _('%s was already asked to join this mailing list') % @person.name
    end

    redirect_to action: :edit
  end

  def unsubscribe
    @person = profile.members.find(params[:id])
    @group = profile

    begin
      @client.unsubscribe_person_from_group_list(@person, @group)
      session[:notice] = _('%s was unsubscribed from this mailing list') % @person.name
    rescue
      session[:notice] = _('%s could not be unsubscribed from this mailing list') % @person.name
    end

    redirect_to action: :edit
  end

  def deploy
    begin
      @client.deploy_list_for_group(profile)
      session[:notice] = _('The mailing list is now deployed!')
    rescue
      session[:notice] = _('The mailing list could not be deployed')
    end
    redirect_to action: :edit
  end

  private

  def update_watched_contents(profile, watched_contents)
    current_watched_contents = profile.articles.with_plugin_metadata(MailingListPlugin, {watched: true})
    new_watched_contents = profile.articles.find(watched_contents.split(','))
    to_add = new_watched_contents - current_watched_contents
    to_remove = current_watched_contents - new_watched_contents

    to_add.each do |content_id|
      content = profile.articles.find content_id
      metadata = Noosfero::Plugin::Metadata.new content, MailingListPlugin
      metadata.watched = true
      metadata.save!
    end

    to_remove.each do |content_id|
      content = profile.articles.find content_id
      metadata = Noosfero::Plugin::Metadata.new content, MailingListPlugin
      metadata.watched = false
      metadata.save!
    end
  end
end
