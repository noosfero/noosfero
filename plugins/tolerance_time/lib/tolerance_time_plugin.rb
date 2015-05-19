class ToleranceTimePlugin < Noosfero::Plugin

  def self.plugin_name
    "Tolerance Time"
  end

  def self.plugin_description
    _("Adds a tolerance time for editing content after its publication")
  end

  def self.expired?(content)
    return false if content.kind_of?(Comment) && !content.article.kind_of?(Article)

    expirable = content.kind_of?(Comment) || (!content.folder? && content.published?)
    publication = ToleranceTimePlugin::Publication.find_by_target(content)
    publication = ToleranceTimePlugin::Publication.create!(:target => content) if expirable && publication.nil?
    person_article = content.kind_of?(Article) && content.profile.kind_of?(Person)

    !person_article && expirable && publication.expired?
  end

  def control_panel_buttons
    {:title => _('Tolerance Adjustements'), :url => {:controller => 'tolerance_time_plugin_myprofile', :profile => context.profile.identifier}, :icon => 'tolerance-time'  }
  end

  def stylesheet?
    true
  end

  def cms_controller_filters
    block = proc do
      content = Article.find(params[:id])
      if ToleranceTimePlugin.expired?(content)
        session[:notice] = _("This content can't be edited anymore because it expired the tolerance time")
        redirect_to content.url
      end
    end
    { :type => 'before_filter',
      :method_name => 'expired_content',
      :options => {:only => 'edit'},
      :block => block }
  end

  def content_viewer_controller_filters
    block = proc do
      content = Comment.find(params[:id])
      if ToleranceTimePlugin.expired?(content)
        session[:notice] = _("This content can't be edited anymore because it expired the tolerance time")
        redirect_to content.article.url
      end
    end
    { :type => 'before_filter',
      :method_name => 'expired_content',
      :options => {:only => 'edit_comment'},
      :block => block }
  end

  def content_expire_edit(content)
    content_expire_for(content, _('editing'))
  end

  def content_expire_clone(content)
    content_expire_for(content, _('cloning'))
  end

  private

  def content_expire_for(content, action)
    if ToleranceTimePlugin.expired?(content)
      _('The tolerance time for %s this content is over.') % action
    end
  end
end
