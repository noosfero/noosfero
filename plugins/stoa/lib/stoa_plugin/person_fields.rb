module StoaPlugin::PersonFields
  HEAVY = %w[image_base64]
  SENSITIVE = %w[]
  FILTER = %w[image]

  ESSENTIAL = %w[username email nusp]
  AVERAGE = ESSENTIAL + %w[name first_name surname address homepage]
  FULL = (AVERAGE + Person.fields + HEAVY - FILTER).uniq
  COMPLETE = FULL - HEAVY

  FIELDS = {
    'none' => {},
    'essential' => ESSENTIAL,
    'average' => AVERAGE,
    'full' => FULL,
    'complete' => COMPLETE
  }
end
