class Html5VideoPlugin < Noosfero::Plugin

  def self.plugin_name
    "HTML5 Video"
  end

  def stylesheet?
    true
  end

  def js_files
    ['video-channel.js']
  end

  def self.plugin_description
    _("A plugin to enable the video suport, with auto conversion for the web.")
  end

  def self.config
    @config ||= YAML.load_file(File.join(root_path, 'config.yml'))
                    .with_indifferent_access
  end

  def content_types
    [Html5VideoPlugin::VideoChannel]
  end

  def view_page_layout(controller, page)
    if FilePresenter.for(page).is_a? FilePresenter::Video and controller.params[:display] == 'iframe'
      'html5_video_plugin_iframe'
    end
  end

  def uploaded_file_after_create_callback(uploaded_file)
    full_filename = uploaded_file.full_filename
    file_presenter = FilePresenter.for(uploaded_file)
    if file_presenter.is_a? FilePresenter::Video
      job = Html5VideoPlugin::EnqueueVideoConversionJob.new
      job.file_type = uploaded_file.class.name
      job.file_id = uploaded_file.id
      job.full_filename = full_filename
      Delayed::Job.enqueue job, priority: 10
    end
  end
end
