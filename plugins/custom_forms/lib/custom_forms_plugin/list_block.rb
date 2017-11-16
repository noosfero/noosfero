module CustomFormsPlugin::ListBlock
  extend ActiveSupport::Concern

  included do
    def self.status_options
      {
        'all' => _('All'),
        'not_closed' => _('Open'),
        'closed' => _('Closed'),
        'not_open_yet' => _('Not yet open')
      }
    end
  end

  def limit
    self.metadata['limit'] ? self.metadata['limit'] : 3
  end

  def status
    self.metadata['status'] ? self.metadata['status'] : 'all'
  end

  def list_forms(user)
    owner.forms.
      accessible_to(user, owner).
      send(status).
      by_kind(self.type).
      order(:ending).
      first(limit)
  end

  def valid_status
    errors.add(:metadata, _('Invalid status')) unless CustomFormsPlugin::SurveyBlock.status_options.key?(status)
  end

end
