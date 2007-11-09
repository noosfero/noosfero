module EnterpriseValidationHelper

  def status(create_enterprise)
    if create_enterprise.approved?
      # FIXME: aurelio
      return content_tag('span', _('Approved'), :style => 'color: green; font-weight: bold;')
    end

    if create_enterprise.rejected?
      # FIXME: aurelio
      return content_tag('span', _('Rejected'), :style => 'color: red; font-weight: bold;')
    end
  end

end
