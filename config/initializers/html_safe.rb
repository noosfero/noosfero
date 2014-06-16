#From: https://github.com/coletivoEITA/noosfero-ecosol/blob/57908cde4fe65dfe22298a8a7f6db5dba1e7cc75/config/initializers/html_safe.rb

# Disable Rails html autoescaping. This is due to noosfero using too much helpers/models to output html.
# It it would change too much code and make it hard to maintain.
# FIXME THIS IS SO WRONG
class Object
  def html_safe?
    true
  end
end
