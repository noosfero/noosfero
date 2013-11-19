module StoaPlugin::PersonFields
  HEAVY = %w[image_base64]
  FILTER = %w[image]
  EXTRA = %w[tags communities]
  CUSTOM = %w[first_name surname homepage image_base64 tags communities]

  ESSENTIAL = %w[username email nusp]
  AVERAGE = ESSENTIAL + %w[name first_name surname address homepage]
  FULL = (AVERAGE + Person.fields + HEAVY + EXTRA - FILTER).uniq
  COMPLETE = FULL - HEAVY

  FIELDS = {
    'none' => {},
    'essential' => ESSENTIAL,
    'average' => AVERAGE,
    'full' => FULL,
    'complete' => COMPLETE
  }

  private

  def selected_fields(kind, user)
    fields = FIELDS[kind] || FIELDS['essential']
    return fields.reject { |field| !FIELDS['essential'].include?(field) } unless user.person.public_profile
    fields.reject do |field|
      !user.person.public_fields.include?(field) &&
      !FIELDS['essential'].include?(field) &&
      !CUSTOM.include?(field)
    end
  end
end
