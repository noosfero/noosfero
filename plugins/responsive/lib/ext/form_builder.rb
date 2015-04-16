
class ResponsiveFormBuilder < ActionView::Helpers::FormBuilder

  %w[file_field text_field text_area password_field submit button].each do |method|
    define_method method do |*args, &block|
      options = args.extract_options!
      options[:class] = "#{options[:class]} form-control"
      super(*(args << options), &block)
    end
  end

end

ActionView::Base.default_form_builder = ResponsiveFormBuilder

