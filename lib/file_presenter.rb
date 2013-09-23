# All file presenters must extends `FilePresenter` not only to ensure the
# same interface, but also to make `FilePresenter.for(file)` to work.
class FilePresenter

  # Will return a encapsulated `UploadedFile` or the same object if no
  # one accepts it. That behave allow to give any model to this class,
  # like a Article and have no trouble with that.
  def self.for(f)
    return f if f.is_a? FilePresenter
    klass = FilePresenter.subclasses.sort_by {|class_name|
      class_name.constantize.accepts?(f) || 0
    }.last.constantize
    klass.accepts?(f) ? klass.new(f) : f
  end

  def initialize(f)
    @file = f
  end

  # Allows to use the original `UploadedFile` reference.
  def encapsulated_file
    @file
  end

  def id
    @file.id
  end

  def reload
    @file.reload
    self
  end

  # This method must be overridden in subclasses.
  #
  # If the class accepts the file, return a number that represents the
  # priority the class should be given to handle that file. Higher numbers
  # mean higher priority.
  #
  # If the class does not accept the file, return false.
  def self.accepts?(f)
    nil
  end

  def short_description
    _("File (%s)") % content_type.sub(/^application\//, '').sub(/^x-/, '').sub(/^image\//, '')
  end

  # Define the css classes to style the page fragment with the file related
  # content. If you want other classes to identify this area to your
  # customized presenter, so do this:
  #   def css_class_list
  #     [super, 'myclass'].flatten
  #   end
  def css_class_list
    [ @file.css_class_list,
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
    lambda do
      render :partial => file.class.to_s.underscore,
             :locals => { :options => options },
             :object => file
    end
  end

  # That makes the presenter to works like any other `UploadedFile` instance.
  def method_missing(m, *args)
    @file.send(m, *args)
  end
end

# Preload FilePresenters to allow `FilePresenter.for()` to work
Dir.glob(File.join('app', 'presenters', '*.rb')) do |file|
  load file
end
