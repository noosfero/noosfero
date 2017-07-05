class MailingListPlugin < Noosfero::Plugin

  def self.plugin_name
    _("Mailing List")
  end

  def self.plugin_description
    _("Integrates Noosfero groups with sympa mailing lists through foruns and blogs.")
  end

  def stylesheet?
    true
  end

  def control_panel_buttons
    buttons = []

    if context.profile.organization?
      buttons << { :title => _('Mailing List'), :icon => 'mailing-list-icon', :url => {:controller => 'mailing_list_plugin_myprofile_organization', :action => 'edit'} }
    end

    if context.profile.person?
      buttons << { :title => _('Mailing List'), :icon => 'mailing-list-icon', :url => {:controller => 'mailing_list_plugin_myprofile_person', :action => 'edit'} }
    end

    buttons
  end

  def member_added(group, person)
     @environment_settings = Noosfero::Plugin::Settings.new group.environment, MailingListPlugin
     @client = MailingListPlugin::Client.new(@environment_settings)
     @client.subscribe_person_on_group_list(person, group)
  end

  def member_removed(group, person)
     @environment_settings = Noosfero::Plugin::Settings.new group.environment, MailingListPlugin
     @client = MailingListPlugin::Client.new(@environment_settings)
     @client.unsubscribe_person_from_group_list(person, group)
  end

  def article_after_create_callback(article)
    watched_content_creation(article, article.parent)
  end

  def comment_after_create_callback(comment)
    watched_content_creation(comment, comment.article.parent)
  end

  private

  def watched_content_creation(content, parent)
    if parent.present?
      profile_settings = Noosfero::Plugin::Settings.new parent.profile, self.class
      parent_metadata = Noosfero::Plugin::Metadata.new parent, self.class
      if profile_settings.enabled && parent_metadata.watched
        if content.kind_of?(Comment)
          reference = content.reply_of || content.source
          reference_metadata = Noosfero::Plugin::Metadata.new reference, self.class
          return if reference_metadata.uuid.blank?
        end
        content_metadata = Noosfero::Plugin::Metadata.new content, self.class
        content_metadata.uuid = SecureRandom.uuid
        content_metadata.save!

        MailingListPlugin::Mailer.reply_email(content).deliver
      end
    end
  end
end
