module Html5VideoPluginTestHelper

  def setup
    rm_tmp_dir
    super
  end

  def teardown
    super
    rm_tmp_dir
  end

  def create_video(file, mime, profile=nil)
    profile ||= fast_create(Person)
    data = fixture_file_upload("/videos/#{file}", mime)
    UploadedFile.create!(uploaded_data: data, profile: profile)
  end

  def process_file(video)
    # Cache video conversions, so it does not run every time
    @@videos ||= {}
    file = video.filename
    if @@videos[file].blank?
      ffmpeg = VideoProcessor::Ffmpeg.new
      logger =  mock
      logger.expects(:info).at_least(0)
      converter = VideoProcessor::Converter.new(ffmpeg, video.full_filename, video.id)
      converter.logger = logger

      @@videos[file] = {}
      @@videos[file][:previews] = converter.create_preview_imgs
      @@videos[file][:web_versions] = get_versions(converter.create_web_videos)
      @@videos[file][:original_video] = converter.info.except :output
    end

    presenter = FilePresenter::Video.new video
    presenter.previews = @@videos[file][:previews]
    presenter.web_versions = @@videos[file][:web_versions]
    presenter.original_video = @@videos[file][:original_video]
    presenter.save
    presenter
  end

  def get_versions(old_versions)
    web_versions = { WEBM: {}, OGV: {} }
    old_versions.each do |format, size_block|
      size_block.each do |size, video|
        conf = video[:conf].clone
        conf[:path] = conf[:out].sub /^.*(\/articles)/, '\1'
        conf.delete :in
        conf.delete :out
        web_versions[format][size] = conf
        web_versions[format][size][:status] = 'done'
      end
    end
    web_versions
  end

  def rm_tmp_dir
    # Removes the pool dir for the test environment
    pool = VideoProcessor::PoolManager.new(Rails.root.to_s)
    FileUtils.rmtree(pool.path)
  end

end
