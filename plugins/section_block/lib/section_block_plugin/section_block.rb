class SectionBlockPlugin::SectionBlock < Block

  attr_accessible :name, :description, :font_color, :background_color

  DEFAULT_SECTION_NAME = 'New Section'
  DEFAULT_BACKGROUND_COLOR = "E6E6E6"
  DEFAULT_FONT_COLOR = "000000"

  settings_items :name, :type => :string, :default => DEFAULT_SECTION_NAME
  settings_items :description, :type => :string
  settings_items :background_color, :type => :string, :default => DEFAULT_BACKGROUND_COLOR
  settings_items :font_color, :type => :string, :default => DEFAULT_FONT_COLOR

  validate :valid_section_name

  def valid_section_name
    errors.add(:name, _('This Section Name is not valid.')) if name.blank?
  end

  before_save :normalize_colors

  before_save do |section|
    raise _('This Section Name is not valid.') if section.name.blank?
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

  def normalize_colors
    normalize_color(background_color, DEFAULT_BACKGROUND_COLOR)
    normalize_color(font_color, DEFAULT_FONT_COLOR)
  end

  def normalize_color(color, default_color)
    color.gsub!('#', '') if color
    color = default_color if color.blank?
  end

  def font_css_inline_style
    return '' if font_color.blank?
    'color: #' + font_color + ';'
  end

  def background_css_inline_style
    return '' if background_color.blank?
    'background-color: #' + background_color + ';'
  end

end
