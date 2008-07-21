require 'noosfero/terminology'

class Zen3Terminology < Noosfero::Terminology::Custom
  include GetText

  def initialize
    super({
      'My Home Page' => N_('My ePortfolio'),
    })
  end

end
