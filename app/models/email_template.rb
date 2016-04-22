class EmailTemplate < ApplicationRecord

  belongs_to :owner, :polymorphic => true

  attr_accessible :template_type, :subject, :body, :owner, :name

  validates_presence_of :name

  validates :name, uniqueness: { scope: [:owner_type, :owner_id] }

  validates :template_type, uniqueness: { scope: [:owner_type, :owner_id] }, if: :unique_by_type?

  def parsed_body(params)
    @parsed_body ||= parse(body, params)
  end

  def parsed_subject(params)
    @parsed_subject ||= parse(subject, params)
  end

  def self.available_types
    {
      :task_rejection => {:description => _('Task Rejection'), :owner_type => Profile},
      :task_acceptance => {:description => _('Task Acceptance'), :owner_type => Profile},
      :organization_members => {:description => _('Organization Members'), :owner_type => Profile},
      :user_activation => {:description => _('User Activation'), :unique => true, :owner_type => Environment},
      :user_change_password => {:description => _('Change User Password'), :unique => true, :owner_type => Environment}
    }
  end

  def available_types
    HashWithIndifferentAccess.new EmailTemplate.available_types.select {|k, v| owner.kind_of?(v[:owner_type])}
  end

  def type_description
    available_types.fetch(template_type, {})[:description]
  end

  def unique_by_type?
    available_types.fetch(template_type, {})[:unique]
  end

  protected

  def parse(source, params)
    template = Liquid::Template.parse(source)
    template.render(HashWithIndifferentAccess.new(params))
  end

end
