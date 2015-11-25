class RawHTMLBlock < Block

  def self.description
    _('Raw HTML')
  end

  def self.pretty_name
    _('Raw HTML')
  end

  settings_items :html, :type => :text

  attr_accessible :html

  def content(args={})
    block = self
    proc do
      render :file => 'blocks/raw_html', :locals => { :block => block }
    end
  end

  def has_macro?
    true
  end

  def editable?(user)
    user.has_permission?('edit_raw_html_block', environment)
  end

end
