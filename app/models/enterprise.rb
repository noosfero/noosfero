#An enterprise is a kind of organization. According to the system concept, only enterprises can offer products/services and ahave to be validated by an validation entity
class Enterprise < Organization
  belongs_to :validation_entity, :class_name => 'organization', :foreign_key => 'validation_entity_id'
  has_one :enterprise_info

  after_create do |enterprise|
    EnterpriseInfo.create!(:enterprise_id => enterprise.id)
  end  
  
  # Test that an enterprise can't be activated unless was previously approved
#  def validate
#    if self.active && !self.approved?
#      errors.add('active', _('Not approved enterprise can\'t be activated'))
#    end
#  end

  # Activate the enterprise so it can be seen by other users
  def activate
    self.active = true
    self.save
  end

  # Approve the enterprise so it can be activated by its owner
  def approve
    enterprise_info.update_attribute('approval_status', 'approved')
  end

  # Reject the approval of the enterprise giving a status message describing its problem
  def reject(msg = 'rejected', comments = '')
    enterprise_info.update_attribute('approval_status', msg)
    enterprise_info.update_attribute('approval_comments', comments)
  end
  
  # Check if the enterprise was approved, that is if the fild approval_status holds the string 'approved'
  def approved?
    enterprise_info.approval_status == 'approved'
  end
  # Check if the enterprise was rejected, that is if the fild approval_status holds the string 'rejected'
  def rejected?
    enterprise_info.approval_status == 'rejected'
  end
end
