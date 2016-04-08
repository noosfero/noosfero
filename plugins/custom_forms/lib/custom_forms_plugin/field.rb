class CustomFormsPlugin::Field < ActiveRecord::Base
  self.table_name = :custom_forms_plugin_fields

  validates_presence_of :name
  validates_length_of :default_value, :maximum => 255

  attr_accessible :name, :form, :mandatory, :type, :position, :default_value, :show_as, :alternatives_attributes

  belongs_to :form, :class_name => 'CustomFormsPlugin::Form'
  has_many :answers, :class_name => 'CustomFormsPlugin::Answer', :dependent => :destroy

  has_many :alternatives, -> { order 'position' }, class_name: 'CustomFormsPlugin::Alternative'
  accepts_nested_attributes_for :alternatives, :allow_destroy => true
  #FIXME This validation should be in the subclass, but since we are using Single Table
  # Inheritance we are instantiating a Field object with the type as a param. So the validation
  # had to go here or rails would skip it.
  validates_length_of :alternatives, :minimum => 1, :message => 'can\'t be empty', :if => Proc.new { |f| f.type == 'CustomFormsPlugin::SelectField' }

  before_validation do |field|
    field.slug = field.name.to_slug if field.name.present?
  end

  private

  def attributes_protected_by_default
    super - [self.class.inheritance_column]
  end

end

