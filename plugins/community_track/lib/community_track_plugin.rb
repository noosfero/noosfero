class CommunityTrackPlugin < Noosfero::Plugin

  def self.plugin_name
    'Community Track'
  end

  def self.plugin_description
    _("New kind of content for communities.")
  end

  def stylesheet?
    true
  end

  def content_types
    if context.kind_of?(CmsController) && context.respond_to?(:params) && context.params
      types = []
      parent_id = context.params[:parent_id]
      types << CommunityTrackPlugin::Track if context.profile.community? && !parent_id
      parent = parent_id ? context.profile.articles.find(parent_id) : nil
      types << CommunityTrackPlugin::Step if parent.kind_of?(CommunityTrackPlugin::Track)
      types
    else
       [CommunityTrackPlugin::Track, CommunityTrackPlugin::Step]
    end
  end

  def self.extra_blocks
    { CommunityTrackPlugin::TrackListBlock => {:position => 1}, CommunityTrackPlugin::TrackCardListBlock => {} }
  end

  def content_remove_new(page)
    page.kind_of?(CommunityTrackPlugin::Track)
  end

end
