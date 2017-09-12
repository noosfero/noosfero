class CustomFormsPlugin::SurveyBlock < Block

  attr_accessible :metadata

  def default_title
    _('Surveys')
  end

  def self.description
    _('Poll list in profile')
  end

  def self.pretty_name
   _('Surveys')
  end

  def help
    _('This block show last polls peformed in profile. auhsuahsuas dhfsauhfusdfh idshfisduhfo iusdh idshofiu dshf') + "ehehehee"
  end

  def provide_partial_results?
    self.metadata['provide_partial_results'] == '1' ? true : false
  end

  def hello
    "Hello"
  end

  def surveys
    CustomFormsPlugin::Form.order(created_at: :desc).last(limit).select do |f|
      case status
      when '1'
        true
      when '2'
        !self.expired?
      when '3'
        self.expired?
      end
    end
  end

end

