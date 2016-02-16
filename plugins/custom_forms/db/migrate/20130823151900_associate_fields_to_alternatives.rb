class AssociateFieldsToAlternatives < ActiveRecord::Migration
  class CustomFormsPlugin::Field < ActiveRecord::Base
    self.table_name = :custom_forms_plugin_fields
    has_many :alternatives, :class_name => 'CustomFormsPlugin::Alternative'
    serialize :choices, Hash
  end

  def self.up
    CustomFormsPlugin::Field.reset_column_information

    CustomFormsPlugin::Field.find_each do |f|
      f.choices.each do |key, value|
        CustomFormsPlugin::Alternative.create!(:label => key, :field_id => f.id)
      end
    end

    CustomFormsPlugin::Answer.find_each do |answer|
      # Avoid crash due to database possible inconsistency on submissions without form
      begin
        labels = []
        answer.value.split(',').each do |value|
          labels << answer.field.choices.invert[value]
        end
        labels.compact!
        if labels.present?
          answer.value = answer.field.alternatives.where('label IN (?)', labels).map(&:id).join(',')
          answer.save!
        end
      rescue
      end
    end

    change_table :custom_forms_plugin_fields do |t|
      t.remove :choices
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
