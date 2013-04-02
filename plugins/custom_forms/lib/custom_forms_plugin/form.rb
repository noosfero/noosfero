class CustomFormsPlugin::Form < Noosfero::Plugin::ActiveRecord
  belongs_to :profile

  has_many :fields, :class_name => 'CustomFormsPlugin::Field', :dependent => :destroy
  has_many :submissions, :class_name => 'CustomFormsPlugin::Submission'

  serialize :access

  validates_presence_of :profile, :name
  validates_uniqueness_of :slug, :scope => :profile_id
  validate :access_format

  before_validation do |form|
    form.slug = form.name.to_slug if form.name.present?
    form.access = nil if form.access.blank?
  end

  named_scope :from, lambda {|profile| {:conditions => {:profile_id => profile.id}}}
  named_scope :on_memberships, {:conditions => {:on_membership => true}}
=begin
  named_scope :accessible_to lambda do |profile| 
    #TODO should verify is profile is associated with the form owner
    profile_associated = ???
    {:conditions => ["
      access IS NULL OR
      (access='logged' AND :profile_present) OR
      (access='associated' AND :profile_associated) OR
      :profile_id in access
    ", {:profile_present => profile.present?, :profile_associated => ???, :profile_id => profile.id}]}
  end
=end

  def expired?
    (begining.present? && Time.now < begining) || (ending.present? && Time.now > ending)
  end

  def accessible_to(target)
    return true if access.nil? || target == profile
    return false if target.nil?
    return true if access == 'logged'
    return true if access == 'associated' && ((profile.organization? && profile.members.include?(target)) || (profile.person? && profile.friends.include?(target)))
    return true if access.kind_of?(Integer) && target.id == access
    return true if access.kind_of?(Array) && access.include?(target.id)
  end

  private

  def access_format
    if access.present?
      if access.kind_of?(String)
        if access != 'logged' && access != 'associated'
          errors.add(:access, _('Invalid string format of access.'))
        end
      elsif access.kind_of?(Integer)
        if !Profile.exists?(access)
          errors.add(:access, _('There is no profile with the provided id.'))
        end
      elsif access.kind_of?(Array)
        access.each do |value|
          if !value.kind_of?(Integer) || !Profile.exists?(value)
            errors.add(:access, _('There is no profile with the provided id.')) 
            break
          end
        end
      else
        errors.add(:access, _('Invalid type format of access.'))
      end
    end
  end
end
