##
# Support for I18n.default_locale
#
require "i18n/backend/fallbacks"
I18n.backend.class.send :include, I18n::Backend::Fallbacks
I18n.enforce_available_locales = false
