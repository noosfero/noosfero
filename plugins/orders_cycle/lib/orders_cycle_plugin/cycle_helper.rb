module OrdersCyclePlugin::CycleHelper

  protected

  def timeline_class cycle, status, selected
    klass = ""
    if cycle.status == status
      klass += " cycle-timeline-current-item"
    elsif cycle.passed_by? status
      klass += " cycle-timeline-passed-item"
    else
      klass += " cycle-timeline-next-item"
    end
    klass += " cycle-timeline-selected-item" if selected == status
    klass
  end

end
