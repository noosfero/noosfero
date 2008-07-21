require 'noosfero/terminology'

class Zen3Terminology < Noosfero::Terminology::Custom
  include GetText

  def initialize
    # NOTE: the hash values must be marked for translation!! 
    super({
      'My Home Page' => N_('My ePortfolio'),
      'Homepage' => N_('ePortfolio'),
      'Communities' => N_('Groups'),
      'A block that displays your communities' => N_('A block that displays your groups'),
      'The communities in which the user is a member' => N_('The groups in which the user is a member'),
      'All communities' => N_('All groups'),
      'Community' => N_('Group'),
      'One community' => N_('One group'),
      '%{num} communities' => N_('%{num} groups'),
      'Disable search for communities' => N_('Disable search for groups'),
    })
  end

end
