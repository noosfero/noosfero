class CommunityTrackPluginPublicController < PublicController

  no_design_blocks

  before_action :login_required, :only => :select_community

  def view_tracks
    @block = Block.find(params[:id])
    instance_eval(&@block.set_seed)
    @p = params[:page].to_i
    @per_page = params[:per_page]
    @per_page ||= @block.limit
    @per_page = @per_page.to_i
    @tracks = @block.tracks(@p, @per_page)
    @force_same_page = params[:force_same_page]

    respond_to do |format|
      format.js
    end
  end

  def all_tracks
    @per_page = 8 #FIXME
    @block = Block.find(params[:id])
    instance_eval(&@block.set_seed)
    @tracks = @block.tracks(1, @per_page)
    @show_more = @block.has_page?(2, @per_page)
  end

  def select_community
    @communities = user.memberships.select{ |community| user.has_permission?('post_content', community) }
    @back_to = request.url
    if request.post?
      community_identifier = params[:community_identifier]
      if community_identifier.nil?
        @failed = [_('Select one community to proceed')]
      else
        redirect_to :controller => 'cms', :action => 'new', :type => "CommunityTrackPlugin::Track", :profile => community_identifier
      end
    end
  end

end
