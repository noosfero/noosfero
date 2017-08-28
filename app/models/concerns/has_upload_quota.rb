module HasUploadQuota
  extend ActiveSupport::Concern

  included do
    validate :upload_quota_size
  end

  def upload_quota
    if metadata.has_key? 'quota'
      metadata['quota'].blank? ? nil : metadata['quota'].to_f
    else
      super_upload_quota
    end
  end

  private

  def upload_quota_size
    float_quota = Float(metadata['quota']) rescue nil
    if metadata['quota'].present? && float_quota.nil?
      errors.add(:quota, _('Invalid value'))
    end
  end

  def super_upload_quota
    # returns the higher upload quota in the hierarchy:
    raise 'not implemented'
  end

end
