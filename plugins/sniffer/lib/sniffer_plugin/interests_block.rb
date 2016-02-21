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

  def content(args = {})
    block = self
    profile = block.owner
    proc do
      if block.owner.is_a?(Profile)
        interests = profile.snnifer_opportunities
        interests |= profile.inputs if sniffer.profile.enterprise?
      else # Environment
        interests = SnifferPlugin::Opportunity.product_categories.limit(5).order('created_at DESC').all
        interests += Input.limit(5).order('created_at DESC').all
        interests.sort{ |a, b| -1 * a.created_at.to_i <=> b.created_at.to_i }
      end

      render :file => 'blocks/sniffer_plugin/interests_block',
        :locals => {:block => block, :interests => interests}
    end
  end

end

