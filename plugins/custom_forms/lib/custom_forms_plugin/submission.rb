class CustomFormsPlugin::Submission < ApplicationRecord

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
    if /\d+/ =~ attrib and (f = CustomFormsPlugin::Field.find_by(id: attrib.to_s))
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
      chosen_alternatives = chosen_alternatives_from_value(value)
      #keeping the value field for text answers.
      answer = self.answers.build :field => field, :value => value
      answer.alternatives << chosen_alternatives
      answer.save!
    end
    self.answers
  end

  def chosen_alternatives_from_value(value)
    begin
      if value.kind_of?(String)
        return CustomFormsPlugin::Alternative.find(value)
      end
      if value.kind_of?(Array)
        alternatives = []
        value.each do |v|
          alternatives << CustomFormsPlugin::Alternative.find(v)  if (v.to_i > 0)
        end
        return alternatives
      end
      if value.kind_of?(Hash)
        alternatives = []
        value.each do |key, value|
          alternatives << CustomFormsPlugin::Alternative.find(key)  if (value.to_i > 0)
        end
        return alternatives
      end
    rescue ActiveRecord::RecordNotFound
      # the field is a text field.
      return []
    end
  end

  def answer_for(field)
    self.answers.find{ |a| a.field == field }
  end

  def q_and_a
    qa = {}
    form.fields.each { |f| qa[f] = answer_for(f) }
    qa
  end

  def has_imported_answers?
    answers.any?(&:imported)
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
