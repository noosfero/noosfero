
class ResponsiveFormBuilder < ActionView::Helpers::FormBuilder

  %w[file_field text_field text_area number_field password_field].each do |method|
    define_method method do |*args, &block|
      options = args.extract_options!
      if options['class']
        options['class'] = "#{options['class']} form-control"
      else
        options[:class] = "#{options[:class]} form-control"
      end
      super(*(args << options), &block)
    end
  end

end

ActionView::Base.default_form_builder = ResponsiveFormBuilder

