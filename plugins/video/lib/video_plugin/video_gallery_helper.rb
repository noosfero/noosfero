module VideoPlugin::VideoGalleryHelper

  def list_videos(configure={})
      configure[:recursive] ||= false
      configure[:list_type] ||= :folder
      if !configure[:contents].blank?
        configure[:contents] = configure[:contents].paginate(
          :per_page => 17,
          :page => params[:npage]
        ).order("updated_at DESC")
        render :file => 'shared/video_list', :locals => configure
      else
        content_tag('em', _('(empty folder)'))
      end
  end

end
