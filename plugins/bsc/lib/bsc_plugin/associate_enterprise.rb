class BscPlugin::AssociateEnterprise < Task

  alias :enterprise :target

  belongs_to :bsc, :class_name => 'BscPlugin::Bsc'

  validates_presence_of :bsc

  def title
    _("BSC association")
  end

  def linked_subject
    {:text => bsc.name, :url => bsc.url}
  end

  def information
    {:message => _('%{requestor} wants to associate this enterprise with %{linked_subject}.')}
  end

  def icon
    src = bsc.image ? bsc.image.public_filename(:minor) : '/images/icons-app/enterprise-minor.png'
    {:type => :defined_image, :src => src, :name => bsc.name}
  end

  def reject_details
    true
  end

  def perform
    bsc.enterprises << enterprise
  end

  def task_finished_message
    _('%{enterprise} accepted your request to associate it with %{bsc}.') % {:enterprise => enterprise.name, :bsc => bsc.name} 
  end

  def task_cancelled_message
    message = _("%{enterprise} rejected your request to associate it with %{bsc}.") % {:enterprise => enterprise.name, :bsc => bsc.name}
    if !reject_explanation.blank?
      message += " " + _("Here is the reject explanation left by the administrator:\n\n%{reject_explanation}") % {:reject_explanation => reject_explanation}
    end
  end

  def target_notification_message
    _('%{requestor} wants assoaciate %{bsc} as your BSC.') % {:requestor => requestor.name, :enterprise => enterprise.name, :bsc => bsc.name} 
  end

end
