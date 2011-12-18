class Noosfero::Plugin::MailerBase < ActionMailer::Base

  def self.inherited(child)
    child.template_root = File.expand_path(File.join(Rails.root, 'plugins', child.plugin_name, 'views'))
  end

  def self.plugin_name
    name.split('::').first.gsub(/Plugin$/, '').underscore
  end

  def initialize_template_class(assigns)
    ActionView::Base.new(view_paths, assigns, self)
  end

end
