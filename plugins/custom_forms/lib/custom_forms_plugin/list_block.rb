module CustomFormsPlugin::ListBlock
  extend ActiveSupport::Concern

  included do
    def self.status_options
      {
        "all" => _("All"),
        "not_closed" => _("Open"),
        "closed" => _("Closed"),
        "not_open_yet" => _("Not yet open")
      }
    end
  end

  def limit
    self.metadata["limit"] ? self.metadata["limit"] : 3
  end

  def status
    self.metadata["status"] ? self.metadata["status"] : "all"
  end

  def list_forms(user)
    forms = owner.forms.accessible_to(user, owner)
    forms = forms.send(status) unless status == "all"
    forms = forms.by_kind(self.type)
    forms = filtered_ids.present? ? forms.where(id: filtered_ids) : forms
    forms.order(:ending).first(limit.to_i)
  end

  def valid_status
    errors.add(:metadata, _("Invalid status")) unless CustomFormsPlugin::SurveyBlock.status_options.key?(status)
  end

  def filtered_forms_to_token
    forms = CustomFormsPlugin::Form.where(kind: self.type, id: filtered_ids)
    forms.map { |f| { id: f.id, name: f.name } }
  end

  private

    def filtered_ids
      (self.metadata["filtered_queries"].to_s || "").split(",")
    end
end
