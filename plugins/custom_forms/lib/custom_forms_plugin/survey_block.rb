class CustomFormsPlugin::SurveyBlock < Block

  attr_accessible :metadata

  validate :valid_status

  def default_title
    _('Surveys')
  end

  def self.description
    _('Surveys list in profile')
  end 

  def self.pretty_name
   _('Surveys')
  end 

  def type
    'survey'
  end

  def help
    _('This block show last surveys peformed in profile.')
  end

  include CustomFormsPlugin::ListBlock

end

