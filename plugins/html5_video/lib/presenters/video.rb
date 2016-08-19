class FilePresenter::Video < FilePresenter

  def self.accepts?(f)
    return nil if !f.respond_to?(:content_type) || f.content_type.nil?
    ( f.content_type[0..4] == 'video' ) ? 10 : nil
  end

  def short_description
    _('Video (%s)') % content_type.split('/')[1].upcase
  end

  def meta_data #video_info
    Noosfero::Plugin::Settings.new(encapsulated_file, Html5VideoPlugin)
  end

  def original_video
    meta_data.original_video ||= {}
  end

  def original_video=(hash)
    meta_data.original_video = hash
  end

  def web_versions
    meta_data.web_versions ||= {}
  end

  def web_versions=(hash)
    meta_data.web_versions = hash
  end

  # adds the orig version tho the web_versions if that is a valid to HTML5
  def web_versions!
    list = web_versions.clone
    streams = original_video.empty? ? [] : original_video[:streams]
    video_stream = streams.find{|s| s[:type] == 'video' }
    audio_stream = streams.find{|s| s[:type] == 'audio' }
    return list unless video_stream && audio_stream
    type = original_video[:type].to_s.upcase.to_sym
    type = :OGV if video_stream[:codec]=='theora' && original_video[:type]=='ogg'
    if [:OGV, :MP4, :WEBM].include? type
      vb = video_stream[:bitrate] || original_video[:global_bitrate] || 0
      ab = audio_stream[:bitrate] || 0
      info = {
        :original => true,
        :file_name => File.basename(public_filename),
        :abrate => ab,
        :vbrate => vb,
        :size => video_stream[:size],
        :size_name => 'orig',
        :status => 'done',
        :type => type,
        :path => public_filename
      }
      list[type][:orig] = info
    end
    list
  end

  def ready_web_versions
    ready = {}
    web_versions!.select do |type, type_block|
      ready[type] = {}
      type_block.select do |size, size_block|
        ready[type][size] = size_block if size_block[:status] == 'done'
      end
    end
    ready
  end

  def has_ogv_version
    not ready_web_versions[:OGV].blank?
  end

  def has_mp4_version
    not ready_web_versions[:MP4].blank?
  end

  def has_webm_version
    not ready_web_versions[:WEBM].blank?
  end

  def has_web_version
    ready = ready_web_versions
    not (ready[:OGV].blank? and ready[:MP4].blank? and ready[:WEBM].blank?)
  end

  def tiniest_web_version( type )
    return nil if ready_web_versions[type].nil?
    video = ready_web_versions[type].
            select{|size,data| data[:status] == 'done' }.
            sort_by{|v| v[1][:vbrate] }.first
    video ? video[1] : nil
  end

  #TODO: add this to the user interface:
  def web_version_jobs
    #FIXME: in a newer version, the Delayed::Job may be searcheable in a uglyless way.
    Delayed::Job.where("handler LIKE '%CreateVideoForWebJob%file_id: #{self.id}%'").all
    #Delayed::Job.all :conditions => ['handler LIKE ?',
    #                                 "%CreateVideoForWebJob%file_id: #{self.id}%"]
  end

  def web_preview_jobs
    #FIXME: in a newer version, the Delayed::Job may be searcheable in a uglyless way.
    Delayed::Job.where("handler LIKE '%CreateVideoPreviewJob%file_id: #{self.id}%'").all
    #Delayed::Job.all :conditions => ['handler LIKE ?',
    #                                 "%CreateVideoPreviewJob%file_id: #{self.id}%"]
  end

  def has_previews?
    not(previews.nil?) && previews.kind_of?(Hash) && !previews.empty?
  end

  def previews
    meta_data.image_previews
  end

  def previews=(hash)
    meta_data.image_previews = hash
  end

  def image_preview(size=nil)
    if has_previews? && previews[size]
      File.dirname( public_filename ) + previews[size]
    else
      "/plugins/html5_video/images/video-preview-#{size}.png"
    end
  end

  def conversion_errors
    errors = {}
    web_versions!.select do |type, type_block|
      type_block.select do |size, conv_info|
        if conv_info[:status] == 'error converting'
          errors[type] ||= {}
          err_base = {:message=>_('Undefined'), :code=>-2, :output=>'undefined'}
          errors[type][size] = err_base.merge( conv_info[:error] || {} )
        end
      end
    end
    errors
  end

end
