module RoleAssignmentTrigger
  def self.included(base)
    base.class_eval do
      before_create do |ra|
        if ra.resource.kind_of?(Profile)
          profile = ra.resource
          person = ra.accessor
          ok = !profile.nil? && !person.nil? && profile.environment.present?
          if ok && profile.environment.plugin_enabled?(CustomFormsPlugin) && !person.is_member_of?(profile)
            CustomFormsPlugin::Form.from(profile).on_memberships.each do |form|
              CustomFormsPlugin::MembershipSurvey.create!(:requestor => profile, :target => person, :form_id => form.id)
            end
          end
        end
      end
  
      after_destroy do |ra|
        if ra.resource.kind_of?(Profile)
          profile = ra.resource
          person = ra.accessor
          ok = !profile.nil? && !person.nil? && profile.environment.present?
          if ok && profile.environment.plugin_enabled?(CustomFormsPlugin) && !person.is_member_of?(profile)
            CustomFormsPlugin::Form.from(profile).on_memberships.each do |form|
              task = person.tasks.pending.select {|task| task.kind_of?(CustomFormsPlugin::MembershipSurvey) && task.form_id == form.id}.first
              task.cancel if task
            end
          end
        end
      end
    end
  end
end

RoleAssignment.send :include, RoleAssignmentTrigger
