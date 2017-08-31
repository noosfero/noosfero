module CustomFormsPlugin::ListBlock
  extend ActiveSupport::Concern

  included do

    def self.status_options
      #TODO Add validations
      {
        'all' => _('All'),
        'open' => _('Open'),
        'closed' => _('Closed'),
        'not_yet_open' => _('Not yet open')
      }
    end
  end

  def limit
    self.metadata['limit'] ? self.metadata['limit'] : 1
  end

  def status
    self.metadata['status'] ? self.metadata['status'] : 'all' 
  end

  def list_forms
    CustomFormsPlugin::Form.send(status).by_kind(self.type).last(limit)
  end

end
