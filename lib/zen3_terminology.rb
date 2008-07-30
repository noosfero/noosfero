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

      'Enterprises' => N_('Organizations'),
      'The enterprises where this user works.' => N_('The organizations where this user works.'),
      'A block that displays your enterprises' => N_('A block that displays your organizations.'),
      'All enterprises' => N_('All organizations'),
      'Disable search for enterprises' => N_('Disable search for organizations'),
      'One enterprise' => N_('One organization'),
      '%{num} enterprises' => N_('%{num} organizations'),
      'Favorite Enterprises' => N_('Favorite Organizations'),
      'This user\'s favorite enterprises.' => N_('This user\'s favorite organizations'),
      'A block that displays your favorite enterprises' => N_('A block that displays your favorite organizations'),
      'All favorite enterprises' => N_('All favorite organizations'),
      'A search for enterprises by products selled and local' => N_('A search for organizations by products selled and local'),
      'Edit message for disabled enterprises' => N_('Edit message for disabled organizations'),
      'Add favorite enterprise' => N_('Add favorite organization'),
      'Validation info is the information the enterprises will see about how your organization processes the enterprises validations it receives: validation methodology, restrictions to the types of enterprises the organization validates etc.' => N_('Validation info is the information the organizations will see about how your organization processes the organizations validations it receives: validation methodology, restrictions to the types of organizations the organization validates etc.'),
      'Here are all <b>%s</b>\'s enterprises.' => N_('Here all all <b>%s</b>\'s organizations.'),
      'Here are all <b>%s</b>\'s favorite enterprises.' => N_('Here are all <b>%s</b>\'s favorite organizations.'),
      'Favorite Enterprises' => N_('Favorite Organizations'),
      'Enterprises in "%s"' => N_('Organizations in "%s"'),
      'Register a new Enterprise' => N_('Register a new organization'),
      'One friend' => N_('One contact'),
      '%d friends' => N_('%d contacts'),
      'One community' => N_('One group'),
      '%d communities' => N_('%d groups'),
    })
  end

end
