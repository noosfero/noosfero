require 'csv'

class Exporter
  attr_reader :base_fields, :related_fields, :method_fields

  def initialize(collection, fields)
    @collection = collection
    @base_fields = fields[:base] || []
    @method_fields = fields[:methods] || []
    @related_fields = fields.except(:base, :methods)
  end

  def to_xml
    @collection.to_xml({ skip_types: true }.merge(xml_fields))
  end

  def to_csv
    CSV.generate do |csv|
      csv << csv_columns
      @collection.each do |entry|
        csv << csv_line_for(entry)
      end
    end
  end

  private

  def csv_columns
    (base_fields + method_fields +
       @related_fields.map { |_, cols| cols }.flatten).map { |field| _(field.humanize) }
  end

  def csv_line_for(entry)
    field_values = (base_fields + method_fields).map do |field|
      entry.send(field)
    end

    related_fields.each do |relation, fields|
      fields.each do |field|
        field_values << entry.send(relation).send(field)
      end
    end

    field_values
  end

  def xml_fields
    fields = related_fields.map do |rel, cols|
      [:include, { rel => { only: cols } }]
    end.to_h
    fields.merge(only: base_fields, methods: method_fields)
  end
end
