# Inpired on https://github.com/curtis/honeypot-captcha
require_dependency File.join(File.dirname(__FILE__), 'lib', 'form_tag_helper')

module Honeypot
  def honeypot_fields
    { :honeypot => _('Do not fill in this field') }
  end

  def protect_from_bots
    head :ok if honeypot_fields.any? { |f,l| !params[f].blank? }
  end

  def self.included(base)
    base.send :helper_method, :honeypot_fields
  end
end

ActionController::Base.send(:include, Honeypot) if defined?(ActionController::Base)
