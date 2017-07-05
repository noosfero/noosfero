class MailingListPluginMyprofilePersonController < MailingListPluginMyprofileController

  def edit
    @collection = profile.memberships
    super
  end

  def subscribe
    @person = profile
    @group = profile.memberships.find(params[:id])

    if @group.admins.include?(user) || @group.environment.admins.include?(user) # Group admin trying to subscribe herself/himself to the mailing list
      @client.subscribe_person_on_group_list(@person, @group)
      session[:notice] = _('You just subscribed to %s\'s mailing list') % @group.name
    elsif MailingListPlugin::SubscribeMember.ongoing_subscription?(@person, @group) # Member accepts group's request to subscribe to the mailing list
      ongoing_subscription = MailingListPlugin::SubscribeMember.ongoing_subscription(@person, @group)
      ongoing_subscription.finish
      session[:notice] = _('The request from %s\'s to subscribe you to it\'s mailing list was accepted') % @group.name
    elsif !MailingListPlugin::AcceptSubscription.ongoing_subscription?(@person, @group) # Member to subscribe to the group mailing list
      task = MailingListPlugin::AcceptSubscription.new(:requestor => user, :target => @group)
      task.metadata['person_id'] = @person.id
      task.save!
      session[:notice] = _('%s was asked to accept your subscription to the mailing list') % @group.name
    else # Member already asked to join the group's mailing list
      session[:notice] = _('%s was already asked to accept your subscription to the mailing list') % @group.name
    end

    redirect_to action: :edit
  end

  def unsubscribe
    @person = profile
    @group = profile.memberships.find(params[:id])

    begin
      @client.unsubscribe_person_from_group_list(@person, @group)
      session[:notice] = _('You were unsubscribed from %s\'s mailing list') % @group.name
    rescue
      session[:notice] = _('You could not be unsubscribed from %s\'s mailing list') % @group.name
    end

    redirect_to action: :edit
  end

  def unsubscribe_all
    Delayed::Job.enqueue MailingListPlugin::UnsubscribeAllJob.new(profile.id)
    session[:notice] = _('The operation was scheduled, you will be unsubscribed from all lists shortly')

    redirect_to action: :edit
  end
end
