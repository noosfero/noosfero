class Html5VideoPlugin < Noosfero::Plugin

  FilePresenter::Video

  def self.plugin_name
    "HTML5 Video"
  end

  def self.plugin_description
    _("A plugin to enable the video suport, with auto conversion for the web.")
  end

end
