class TagsBlock < Block

  include TagsHelper
  include BlockHelper
  include ActionView::Helpers
  include Rails.application.routes.url_helpers

  settings_items :limit, :type => :integer, :default => 12

  def self.description
    _('<p>Display a tag cloud with the content produced where the block is applied.</p> <p>The user could limit the number of tags will be displayed.</p>')
  end

  def self.short_description
    _('Display a tag cloud about current content')
  end

  def self.pretty_name
    _('Tag Cloud')
  end

  def default_title
    _('tags')
  end

  def help
    _("Tags are created when you add some of them one to your contents. <p/>
       Try to add some tags to some articles and you'l see your tag cloud growing.")
  end

  def content(args={})
    block = self
    proc do
      render :file => 'blocks/tags', :locals => { :block => block }
    end
  end

  def footer
    if owner.class == Environment
      proc do
        link_to s_('tags|View all'),
          :controller => 'search', :action => 'tags'
      end
    else
      owner_id = owner.identifier
      proc do
        link_to s_('tags|View all'),
          :profile => owner_id, :controller => 'profile', :action => 'tags'
      end
    end
  end

  def timeout
    15.minutes
  end

  def self.expire_on
      { :profile => [:article], :environment => [:article] }
  end

end
