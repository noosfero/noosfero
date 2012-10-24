class CustomFormsPlugin::Submission < Noosfero::Plugin::ActiveRecord
  belongs_to :form, :class_name => 'CustomFormsPlugin::Form'
  belongs_to :profile

  has_many :answers, :class_name => 'CustomFormsPlugin::Answer'

  validates_presence_of :form
  validates_presence_of :author_name, :author_email, :if => lambda {|submission| submission.profile.nil?}
  validates_uniqueness_of :author_email, :scope => :form_id, :allow_nil => true
  validates_format_of :author_email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda {|submission| !submission.author_email.blank?})
end

