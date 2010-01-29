class DocItem
  attr_accessor :id, :title, :text, :language
  def initialize(attrs = {})
    attrs.each do |name,value|
      self.send("#{name}=", value)
    end
    self.language ||= 'en'
  end

  def html(theme = nil)
    text.gsub(/<img src="([^"]+\.en\.png)"/) do |match|
      path = $1
      translation = find_image_replacement(path, theme)
      if translation
        "<img src=\"#{translation}\""
      else
        match
      end
    end
  end

  private

  def find_image_replacement(image, theme)
    translation = image.sub(/\.en\.png$/, '.' + language + '.png')
    search_path = [
      translation
    ]
    if theme
      search_path.unshift("/designs/themes/#{theme}#{translation}") # higher priority
      search_path.push("/designs/themes/#{theme}#{image}") # lower priority
    end
    search_path.find {|file| File.exist?("#{RAILS_ROOT}/public#{file}") }
  end

end
