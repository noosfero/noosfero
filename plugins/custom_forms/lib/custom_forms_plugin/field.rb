class CustomFormsPlugin::Field < ApplicationRecord
  self.table_name = :custom_forms_plugin_fields

  validates_presence_of :name
  validates_length_of :default_value, :maximum => 255

  attr_accessible :name, :form, :mandatory, :type, :position, :default_value, :show_as, :alternatives_attributes

  belongs_to :form, class_name: 'CustomFormsPlugin::Form', optional: true
  has_many :answers, class_name: 'CustomFormsPlugin::Answer', dependent: :destroy

  has_many :alternatives, -> { order 'position' }, class_name: 'CustomFormsPlugin::Alternative'
  accepts_nested_attributes_for :alternatives, :allow_destroy => true
  #FIXME This validation should be in the subclass, but since we are using Single Table
  # Inheritance we are instantiating a Field object with the type as a param. So the validation
  # had to go here or rails would skip it.
  validates_length_of :alternatives, :minimum => 1, :message => 'can\'t be empty', :if => Proc.new { |f| f.type == 'CustomFormsPlugin::SelectField' }

  before_validation do |field|
    field.slug = field.name.to_slug if field.name.present?
  end

  before_save do |field|

    if form != nil && form.kind == 'poll'
      field.mandatory = true
    end
  end

  def accept_multiple_answers?
    self.show_as.in? ['check_box', 'multiple_select']
  end

  def summary
    summary = {}
    answers.each do |answer|
      answer.to_text_list
            .map{ |v| [v, answer.imported] }
            .each do |value, imported|
        summary[value] ||= { online: 0, offline: 0 }
        key = imported ? :offline : :online
        summary[value][key] += 1
      end
    end

    summary.each do |_, values|
      total = (values[:online] + values[:offline]).to_f
      values[:online] = (values[:online] / total).round(2) * 100
      values[:offline] = (values[:offline] / total).round(2) * 100
    end
  end

  private

  def attributes_protected_by_default
    super - [self.class.inheritance_column]
  end

end
