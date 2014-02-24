class CommunityTrackPlugin::ActivationJob < Struct.new(:step_id)

  def self.find(step_id)
    Delayed::Job.where(:handler => "--- !ruby/struct:CommunityTrackPlugin::ActivationJob\nstep_id: #{step_id}\n")
  end

  def perform
    step = CommunityTrackPlugin::Step.find(step_id)
    step.toggle_activation
  end

end
