module StoaPlugin::PersonFields
  HEAVY = %w[image_base64]
  FILTER = %w[image]
  EXTRA = %w[tags]

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
end
