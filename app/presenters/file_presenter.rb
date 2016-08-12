class FilePresenter < Presenter
  def self.base_class
    Article
  end

  def self.available?(instance)
    instance.kind_of?(UploadedFile) && !instance.kind_of?(Image)
  end

  def download? view = nil
    view.blank?
  end

  def short_description
    file_type = if content_type.present?
      content_type.sub(/^application\//, '').sub(/^x-/, '').sub(/^image\//, '')
    else
      _('Unknown')
    end
    _("File (%s)") % file_type
  end

  # Define the css classes to style the page fragment with the file related
  # content. If you want other classes to identify this area to your
  # customized presenter, so do this:
  #   def css_class_list
  #     [super, 'myclass'].flatten
  #   end
  def css_class_list
    [ encapsulated_instance.css_class_list,
      'file-' + self.class.to_s.split(/:+/).map(&:underscore)[1..-1].join('-'),
      'content-type_' + self.content_type.split('/')[0],
      'content-type_' + self.content_type.gsub(/[^a-z0-9]/i,'-')
    ].flatten
  end

  # Enable file presenter to customize the css classes on view_page.rhtml
  # You may not overwrite this method on your customized presenter.
  def css_class_name
    [css_class_list].flatten.compact.join(' ')
  end

  # The generic icon class-name or the specific file path.
  # You may replace this method on your custom FilePresenter.
  # See the current used icons class-names in public/designs/icons/tango/style.css
  def icon_name
    if mime_type
      [ mime_type.split('/')[0], mime_type.gsub(/[^a-z0-9]/i, '-') ]
    else
      'upload-file'
    end
  end

  # Automatic render `file_presenter/<custom>.html.erb` to display your
  # custom presenter html content.
  # You may not overwrite this method on your customized presenter.
  # A variable with the same presenter name will be created to refer
  # to the file object.
  # Example:
  # The `FilePresenter::Image` render `file_presenter/image.html.erb`
  # inside the `file_presenter/image.html.erb` you can access the
  # required `FilePresenter::Image` instance in the `image` variable.
  def to_html(options = {})
    file = self
    proc do
      render :partial => file.class.to_s.underscore,
             :locals => { :options => options },
             :object => file
    end
  end
end

Dir.glob(File.join('app', 'presenters', 'file', '*.rb')) do |file|
  load file
end

# Preload FilePresenters from plugins to allow `FilePresenter.for()` to work
Dir.glob(File.join('plugins', '*', 'lib', 'presenters', '*.rb')) do |file|
  load file
end
