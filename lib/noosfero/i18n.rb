require 'fast_gettext'

class Object
  include FastGettext::Translation
  alias :gettext :_
  alias :ngettext :n_
end

class ActiveRecord::Errors
  default_error_messages.update(
    :inclusion => "%{fn} is not included in the list",
    :exclusion => "%{fn} is reserved",
    :invalid => "%{fn} is invalid",
    :confirmation => "%{fn} doesn't match confirmation",
    :accepted  => "%{fn} must be accepted",
    :empty => "%{fn} can't be empty",
    :blank => "%{fn} can't be blank",
    :too_long => "%{fn} is too long (maximum is %d characters)",
    :too_short => "%{fn} is too short (minimum is %d characters)",
    :wrong_length => "%{fn} is the wrong length (should be %d characters)",
    :taken => "%{fn} has already been taken",
    :not_a_number => "%{fn} is not a number"
  )

  def localize_error_messages
    errors = {}
    each do |attr,msg|
      next if msg.nil?
      errors[attr] ||= []
      errors[attr] << _(msg).sub('%{fn}', @base.class.human_attribute_name(attr))
    end
    errors
  end
  def on_with_gettext(attribute)
    errors = localize_error_messages[attribute.to_s]
    return nil if errors.nil?
    errors.size == 1 ? errors.first : errors
  end
  alias_method_chain :on, :gettext

  def full_messages_with_gettext
    full_messages = []
    errors = localize_error_messages
    errors.each_key do |attr|
      errors[attr].each do |msg|
        next if msg.nil?
        full_messages << msg
      end
    end
    full_messages
  end
  alias_method_chain :full_messages, :gettext
end


module ActionView::Helpers::ActiveRecordHelper
  module L10n
    @error_message_title = ["%{num} error prohibited this %{record} from being saved", "%{num} errors prohibited this %{record} from being saved"]
    @error_message_explanation = ["There was a problem with the following field:", "There were problems with the following fields:"]
    module_function
    def error_messages_for(instance, objects, object_names, count, options)
      record = _(options[:object_name] || object_names[0].to_s)

      html = {}
      [:id, :class].each do |key|
        if options.include?(key)
          value = options[key]
          html[key] = value unless value.blank?
        else
          html[key] = 'errorExplanation'
        end
      end

      if options[:header_message]
        header_message = options[:header_message]
      elsif options[:message_title]
        header_message = instance.error_message(options[:message_title], count) % {:num => count, :record => record}
      else
        header_message = ((count == 1) ? _(@error_message_title[0]) : _(@error_message_title[1])) % {:num => count, :record => record}
      end
      if options[:message_explanation]
        message_explanation = instance.error_message(options[:message_explanation], count) % {:num => count}
      else
        message_explanation = (count == 1 ? _(@error_message_explanation[0]) : _(@error_message_explanation[1])) % {:num => count}
      end

      error_messages = objects.map {|object| object.errors.full_messages.map {|msg| instance.content_tag(:li, msg) } }

      instance.content_tag(
        :div,
        instance.content_tag(options[:header_tag] || :h2, header_message) <<
        instance.content_tag(:p, message_explanation) <<
        instance.content_tag(:ul, error_messages),
          html
      )
    end
  end

  alias error_messages_for_without_localize error_messages_for #:nodoc:

  # error_messages_for overrides original method with localization.
  # And also it extends to be able to replace the title/explanation of the header of the error dialog. (Since 1.90)
  # If you want to override these messages in the whole application, 
  #    use ActionView::Helpers::ActiveRecordHelper::L10n.set_error_message_(title|explanation) instead.
  # * :message_title - the title of message. Use Nn_() to path the strings for singular/plural.
  #                       e.g. Nn_("%{num} error prohibited this %{record} from being saved", 
  # 			       "%{num} errors prohibited this %{record} from being saved")
  # * :message_explanation - the explanation of message
  #                       e.g. Nn_("There was a problem with the following field:", 
  #                                "There were %{num} problems with the following fields:")
  def error_messages_for(*params)
    options = params.last.is_a?(Hash) ? params.pop.symbolize_keys : {}
    objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
    object_names = params.dup
    count   = objects.inject(0) {|sum, object| sum + object.errors.count }
    if count.zero?
          ''
    else
      L10n.error_messages_for(self, objects, object_names, count, options)
    end
  end

end

module ActionController::Caching::Fragments
  def fragment_cache_key_with_fast_gettext(name)
    ret = fragment_cache_key_without_fast_gettext(name)
    if ret.is_a? String
      ret.gsub(/:/, ".") << "_#{FastGettext.locale}"
    else
      ret
    end
  end
  alias_method_chain :fragment_cache_key, :fast_gettext

  def expire_fragment_with_fast_gettext(name, options = nil)
    return unless perform_caching

    key = fragment_cache_key_without_fast_gettext(name)
    if key.is_a?(Regexp)
      self.class.benchmark "Expired fragments matching: #{key.source}" do
        cache_store.delete_matched(key, options)
      end
    else
      key = key.gsub(/:/, ".")
      self.class.benchmark "Expired fragment: #{key}, lang = #{FastGettext.available_locales.inspect}" do
        if FastGettext.available_locales
          FastGettext.available_locales.each do |lang|
            cache_store.delete("#{key}_#{lang}", options)
          end
        end
      end
    end
  end
  alias_method_chain :expire_fragment, :fast_gettext
end

# translations in place?
if File.exists?(Rails.root + '/locale')
  repos = [
    FastGettext::TranslationRepository.build('noosfero', :type => 'mo', :path => Rails.root + '/locale'),
    FastGettext::TranslationRepository.build('iso_3166', :type => 'mo', :path => Rails.root + '/locale'),
    FastGettext::TranslationRepository.build('rails',    :type => 'mo', :path => Rails.root + '/locale'),
  ]

  FastGettext.add_text_domain 'noosferofull', :type => :chain, :chain => repos
  FastGettext.default_text_domain = 'noosferofull'
end
