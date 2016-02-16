module RoleAssignmentTrigger
  def self.included(base)
    base.class_eval do
      before_create do |ra|
        if ra.resource.kind_of?(Profile)
          profile = ra.resource
          person = ra.accessor
          ok = !profile.nil? && !person.nil? && profile.environment.present?
          if ok && profile.environment.plugin_enabled?(CustomFormsPlugin) && !person.is_member_of?(profile)
            CustomFormsPlugin::Form.from_profile(profile).on_memberships.each do |form|
              CustomFormsPlugin::MembershipSurvey.create!(:requestor => profile, :target => person, :form_id => form.id)
            end
          end
        end
      end

      before_validation :on => :create do |ra|
        proceed_creation = true
        if ra.resource.kind_of?(Profile)
          profile = ra.resource
          person = ra.accessor
          ok = !profile.nil? && !person.nil? && profile.environment.present?
          if ok && profile.environment.plugin_enabled?(CustomFormsPlugin) && !person.is_member_of?(profile)
            CustomFormsPlugin::Form.from_profile(profile).for_admissions.each do |form|
              admission_task_pending = person.tasks.pending.select {|task| task.kind_of?(CustomFormsPlugin::AdmissionSurvey) && task.form_id == form.id }.present?
              admission_task_finished = person.tasks.finished.select {|task| task.kind_of?(CustomFormsPlugin::AdmissionSurvey) && task.form_id == form.id }.present?

              CustomFormsPlugin::AdmissionSurvey.create!(:requestor => profile, :target => person, :form_id => form.id) unless admission_task_finished || admission_task_pending
              proceed_creation = false unless admission_task_finished
            end
          end
        end
        proceed_creation
      end

      after_destroy do |ra|
        if ra.resource.kind_of?(Profile)
          profile = ra.resource
          person = ra.accessor
          ok = !profile.nil? && !person.nil? && profile.environment.present?
          if ok && profile.environment.plugin_enabled?(CustomFormsPlugin) && !person.is_member_of?(profile)
            CustomFormsPlugin::Form.from_profile(profile).on_memberships.each do |form|
              task = person.tasks.pending.select {|task| task.kind_of?(CustomFormsPlugin::MembershipSurvey) && task.form_id == form.id}.first
              task.cancel if task
            end
            CustomFormsPlugin::Form.from_profile(profile).for_admissions.each do |form|
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
