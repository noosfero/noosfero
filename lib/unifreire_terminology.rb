require 'noosfero/terminology'

class UnifreireTerminology < Noosfero::Terminology::Custom
  include GetText

  def initialize
    # NOTE: the hash values must be marked for translation!! 
    super({
      'Enterprises' => N_('Institutions'),
      'enterprises' => N_('institutions'),
      'The enterprises where this user works.' => N_('The institution where this user belongs.'),
      'A block that displays your enterprises' => N_('A block that displays your institutions.'),
      'All enterprises' => N_('All institutions'),
      'Disable search for enterprises' => N_('Disable search for institutions'),
      'One enterprise' => N_('One institution'),
      '%{num} enterprises' => N_('%{num} institutions'),
      'Favorite Enterprises' => N_('Favorite Institutions'),
      'This user\'s favorite enterprises.' => N_('This user\'s favorite institutions'),
      'A block that displays your favorite enterprises' => N_('A block that displays your favorite institutions'),
      'All favorite enterprises' => N_('All favorite institutions'),
      'A search for enterprises by products selled and local' => N_('A search for institutions by products selled and local'),
      'Edit message for disabled enterprises' => N_('Edit message for disabled institutions'),
      'Add favorite enterprise' => N_('Add favorite institution'),
      'Validation info is the information the enterprises will see about how your organization processes the enterprises validations it receives: validation methodology, restrictions to the types of enterprises the organization validates etc.' => N_('Validation info is the information the institutions will see about how your organization processes the institutions validations it receives: validation methodology, restrictions to the types of institutions the organization validates etc.'),
      'Here are all <b>%s</b>\'s enterprises.' => N_('Here are all <b>%s</b>\'s institutions.'),
      'Here are all <b>%s</b>\'s favorite enterprises.' => N_('Here are all <b>%s</b>\'s favorite institutions.'),
      'Favorite Enterprises' => N_('Favorite Institutions'),
      'Enterprises in "%s"' => N_('Institutions in "%s"'),
      'Register a new Enterprise' => N_('Register a new Institution'),
      'Events' => N_('Schedule'),
      'Manage enterprise fields' => N_('Manage institutions fields'),
      "%s's enterprises" => N_("%s's institutions"),
      'Activate your enterprise' => N_('Activate your institution'),
      'Enterprise activation code' => N_('Institution activation code'),
      'Disable activation of enterprises' => N_('Disable activation of institutions'),
      "%s's favorite enterprises" => N_("%s's favorite institutions"),
      'Disable Enterprise' => N_('Disable Institution'),
      'Enable Enterprise' => N_('Enable Institution'),
      'Enterprise Validation' => N_('Institution Validation'),
      'Enterprise Info and settings' => N('Institution Info and settings'),
    })
  end

end
