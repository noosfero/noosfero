class CustomFormsPlugin::Field < ActiveRecord::Base
  set_table_name :custom_forms_plugin_fields

  validates_presence_of :form, :name
  validates_uniqueness_of :slug, :scope => :form_id

  belongs_to :form, :class_name => 'CustomFormsPlugin::Form'
  has_many :answers, :class_name => 'CustomFormsPlugin::Answer'

  serialize :choices, Hash

  before_validation do |field|
    field.slug = field.name.to_slug if field.name.present?
  end

  before_create do |field|
    if field.form.fields.exists?
      field.position = field.form.fields.order(:position).last.position + 1
    end
  end

  def position
    self[:position] || 0
  end
end

