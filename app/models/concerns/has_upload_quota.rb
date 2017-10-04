module HasUploadQuota
  extend ActiveSupport::Concern

  included do
    attr_accessible :upload_quota
    validate :upload_quota_size
  end

  def upload_quota
    if self['upload_quota'].nil?
      # If the value was not set, return the upload_quota for the super type
      super_upload_quota
    else
      # Otherwise:
      # - returns nil if the quota is blank, so the upload is unlimited
      # - or return the upload_quota as a float, if it is a number
      self['upload_quota'].blank? ? nil : self['upload_quota'].to_f
    end
  end

  private

  def upload_quota_size
    float_quota = Float(self['upload_quota']) rescue nil
    if self['upload_quota'].present? && float_quota.nil?
      errors.add(:upload_quota, _('Invalid value'))
    elsif float_quota.present? && float_quota < 0
      errors.add(:upload_quota, _('Must be greather or equal to zero'))
    end
  end

  def super_upload_quota
    # returns the higher upload quota in the hierarchy:
    raise 'not implemented'
  end

end
