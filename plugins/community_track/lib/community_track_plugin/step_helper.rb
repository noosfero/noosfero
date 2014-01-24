module CommunityTrackPlugin::StepHelper

  def self.status_descriptions
    [_('Closed'), _('Join!'), _('Soon')]
  end

  def self.status_classes
    ['step_finished', 'step_active', 'step_waiting']
  end

  def status_description(step)
    CommunityTrackPlugin::StepHelper.status_descriptions[status_index(step)]
  end

  def status_class(step)
    CommunityTrackPlugin::StepHelper.status_classes[status_index(step)]
  end

  def link_to_step(step, options={}, name=nil)
    url = step.tool ? step.tool.view_url : step.view_url
    link_to url, options do
      block_given? ? yield : name
    end
  end

  protected

  def status_index(step)
    [step.finished?, step.active?, step.waiting?].find_index(true)
  end

end
