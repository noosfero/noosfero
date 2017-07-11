class SectionBlockPlugin::SectionBlock < Block

  attr_accessible :name, :description, :font_color, :background_color

  settings_items :name, :type => :string, :default => _('New Section')
  settings_items :description, :type => :string
  settings_items :background_color, :type => :string
  settings_items :font_color, :type => :string

  before_save :set_default_values

  def initialize(*params)
    super(params)
    self.set_default_values
  end

  def set_default_values
    self.background_color ||= 'E6E6E6'
    self.background_color.gsub!('#', '')
    self.font_color ||= '000000'
    self.font_color.gsub!('#', '')
  end

  def self.description
    _('Section')
  end

  def help
    _('This block acts as a section block')
  end

  def cacheable?
    false
  end

  def css_inline_style
    font_css_inline_style + background_css_inline_style
  end

  def has_description?
    !description.blank?
  end

  private

  def font_css_inline_style
    font_color.blank? ? '' : 'color: #' + font_color + ';'
  end

  def background_css_inline_style
    background_color.blank? ? '' : 'background-color: #' + background_color + ';'
  end

end
