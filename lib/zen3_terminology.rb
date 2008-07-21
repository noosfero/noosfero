require 'noosfero/terminology'

class Zen3Terminology < Noosfero::Terminology::Custom
  include GetText

  def initialize
    # NOTE: the hash values must be marked for translation!! 
    super({
      'My Home Page' => N_('My ePortfolio'),
    })
  end

end
