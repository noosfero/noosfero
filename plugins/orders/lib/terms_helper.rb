raise 'I18n version 0.6.0 is needed for a good string interpolation' unless I18n::VERSION >= '0.6.0'

module TermsHelper

  extend ActiveSupport::Concern

  included do
    include I18nAutoScope
    alias_method_chain :translate, :transformation
    alias_method_chain :translate, :terms_cache
    alias_method_chain :translate, :terms
    alias_method :t, :translate
  end

  I18nSeparator = '.'

  Terms = [:profile, :supplier, :consumer]
  Auxiliars = [
    nil,
    #
    :it, :one,
    :to_it,
    #
    :article, :undefined_article,
    :in, :which, :this, :your,
    :at, :at_article,
    :to, :to_article,
    :on, :on_your, :on_undefined_article,
    :by, :by_article, :by_your,
    :of, :of_article, :of_this, :of_another,
    :from, :from_article, :from_this, :from_which, :from_which_article,
    :with, :with_article, :with_which,
    # adjectives
    :none, :own, :new,
    :by_own, :new_undefined_article
  ]
  Variations = [nil, :singular, :plural]
  Transformations = [:capitalize]

  # FORMAT: terms.term.auxiliar.variation.transformation
  Keys = Terms.map do |term|
    Auxiliars.map do |auxiliar|
      Variations.map do |variation|
        [term, auxiliar, variation].compact.join I18nSeparator
      end
    end
  end.flatten

  @translations = {}
  def self.translations
    @translations
  end

  @cache = {}
  def self.cache
    @cache
  end

  # FIXME: move from here
  def self.hash_diff h1, h2, inverse = true, path = [], &block
    block ||= proc{ |v1, v2| v1 == v2 }

    h1.each do |k1, v1|
      v2 = h2[k1] rescue nil
      new_path = path + [k1]
      next self.hash_diff v1, v2, inverse, new_path, &block if v1.is_a? Hash and v2.present?

      next if block.call v1, v2
      puts "[#{new_path.map(&:inspect).join ']['}]"
      puts "+ #{v1.inspect}"
      puts "- #{v2.inspect}"
    end

    self.hash_diff h2, h1, false, [], &block if inverse
  end
  def self.compare_locales l1, l2
    I18n.backend.send :init_translations
    trs = I18n.backend.send :translations
    self.hash_diff trs[l1], trs[l2], false do |v1, v2|
      ! (v1.present? and v2.blank?)
    end
  end

  protected

  def translate_with_transformation key, options = {}
    translation = translate_without_transformation key, options

    transformation = options[:transformation]
    translation = translation.send transformation if transformation

    translation
  end

  def translate_with_terms_cache key, options = {}
    # we don't support cache with custom options
    return translate_without_terms_cache key, options if options.present?

    cache = (TermsHelper.cache[I18n.locale] ||= {})
    cache = (cache[i18n_scope] ||= {})

    hit = cache[key]
    return hit if hit.present?

    cache[key] = translate_without_terms_cache key, options
  end

  def translate_with_terms key, options = {}
    translation = translate_without_terms key, options
    if translation.nil? or not translation.is_a? String
      # FIXME: don't raise errors unless specified to do so
      #raise "Invalid or empty value for #{key}"
      ""
    else
      translation % translated_terms
    end
  end

  private

  def translated_terms keys = Keys, translations = TermsHelper.translations, transformations = Transformations, sep = I18nSeparator
    translated_terms = (translations[I18n.locale] ||= {})
    translated_terms = (translated_terms[i18n_scope] ||= {})

    return translated_terms if translated_terms.present?

    keys.each do |key|
      translation = self.translate_with_auto_scope "terms#{sep}#{key}", raise: true rescue nil
      next unless translation.is_a? String

      translated_terms["terms#{sep}#{key}".to_sym] = translation
      transformations.each do |transformation|
        translated_terms["terms#{sep}#{key}#{sep}#{transformation}".to_sym] = translation.send transformation
      end
    end
    translated_terms
  end

end
