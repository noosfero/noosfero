class GoogleCsePlugin < Noosfero::Plugin

  def self.plugin_name
    "GoogleCsePlugin"
  end

  def self.plugin_description
    _("A plugin that use the Google Custom Search as Noosfero search engine.")
  end

  def google_id
    context.environment.settings[:google_cse_id]
  end

  def self.results_url_path
    '/plugin/google_cse/results'
  end

  def body_beginning
    unless google_id.blank?
      expanded_template('search-box.rhtml', {:selector => '#top-search, #footer-search', :plugin => self})
    end
  end

end
