class SnifferPlugin::InterestsBlock < Block

  def self.description
    _("Lists declared and inputs interests")
  end

  def self.short_description
    _("Lists interests")
  end

  def default_title
    _('Interests')
  end

  def help
    _("This block show interests of your profile or environment")
  end

  def interests
    results = nil
    profile = self.owner

    if profile.is_a?(Profile)
      results = profile.sniffer_opportunities
      results |= profile.inputs if profile.enterprise?
    else # Environment
      results = SnifferPlugin::Opportunity.product_categories.limit(5).order('created_at DESC').all
      results += Input.limit(5).order('created_at DESC').all
      results.sort{ |a, b| -1 * a.created_at.to_i <=> b.created_at.to_i }
    end

    return results
  end

end

