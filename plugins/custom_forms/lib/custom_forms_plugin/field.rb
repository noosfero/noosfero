class CustomFormsPlugin::Field < ActiveRecord::Base
  set_table_name :custom_forms_plugin_fields

  validates_presence_of :name

  belongs_to :form, :class_name => 'CustomFormsPlugin::Form'
  has_many :answers, :class_name => 'CustomFormsPlugin::Answer'

  has_many :alternatives, :order => 'position', :class_name => 'CustomFormsPlugin::Alternative'
  accepts_nested_attributes_for :alternatives, :allow_destroy => true

  before_validation do |field|
    field.slug = field.name.to_slug if field.name.present?
  end

  private

  def attributes_protected_by_default
    super - [self.class.inheritance_column]
  end

end

