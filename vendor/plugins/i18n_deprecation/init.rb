require 'i18n/version'

if I18n::VERSION > '0.3.7' && Rails::VERSION::STRING < '3.0.0'
  module I18n::Backend::Base
    def warn_syntax_deprecation!
      # nothing
    end
  end
end
