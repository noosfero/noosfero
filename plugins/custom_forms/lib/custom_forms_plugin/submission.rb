class CustomFormsPlugin::Submission < ActiveRecord::Base

  belongs_to :form, :class_name => 'CustomFormsPlugin::Form'
  belongs_to :profile

  # validation is done manually, see below
  has_many :answers, :class_name => 'CustomFormsPlugin::Answer', :dependent => :destroy, :validate => false

  attr_accessible :form, :profile, :author_name, :author_email

  validates_presence_of :form
  validates_presence_of :author_name, :author_email, :if => lambda {|submission| submission.profile.nil?}
  validates_uniqueness_of :author_email, :scope => :form_id, :allow_nil => true
  validates_format_of :author_email, :with => Noosfero::Constants::EMAIL_FORMAT, :if => (lambda {|submission| !submission.author_email.blank?})
  validate :check_answers

  def self.human_attribute_name_with_customization(attrib, options={})
    if /\d+/ =~ attrib and (f = CustomFormsPlugin::Field.find_by_id(attrib.to_s))
      f.name
    else
      _(self.human_attribute_name_without_customization(attrib))
    end
  end
  class << self
    alias_method_chain :human_attribute_name, :customization
  end

  before_create do |submission|
    if submission.profile
      submission.author_name = profile.name
    end
  end

  def build_answers submission
    self.form.fields.each do |field|
      next unless value = submission[field.id.to_s]

      final_value = ''
      if value.kind_of?(String)
        final_value = value
      elsif value.kind_of?(Array)
        final_value = value.join(',')
      elsif value.kind_of?(Hash)
        final_value = value.map {|option, present| present == '1' ? option : nil}.compact.join(',')
      end

      self.answers.build :field => field, :value => final_value
    end

    self.answers
  end

  def q_and_a
    qa = {}
    form.fields.each do |f|
      self.answers.select{|a| a.field == f}.map{|answer| qa[f] = answer }
    end
    qa
  end

  protected

  def check_answers
    self.answers.each do |answer|
      answer.valid?
      answer.errors.each do |attribute, msg|
        self.errors.add answer.field.id.to_s.to_sym, msg if answer.field.present?
      end
    end
  end

end
