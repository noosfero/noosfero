class MovesPeopleAddressToMetadata < ActiveRecord::Migration

  FIELDS = %i[city state country zip_code district address_line2 address_reference]

  def up
    select_all("SELECT id, data, metadata FROM profiles WHERE type = 'Person'"\
               " AND data SIMILAR TO '%(#{FIELDS.join('|')})%'").each do |entry|
      data = YAML.load(entry['data'])
      metadata = JSON.parse(entry['metadata'])
      FIELDS.each do |field|
        if data[field].present?
          metadata[field.to_s] = data[field]
          data.delete(field)
        end
      end
      update_profile(entry["id"], data, metadata)
    end
  end

  def down
    select_all("SELECT id, data, metadata FROM profiles WHERE type = 'Person'"\
               " AND metadata ?| array['#{FIELDS.join("','")}']").each do |entry|
      data = YAML.load(entry['data'])
      metadata = JSON.parse(entry['metadata'])
      FIELDS.each do |field|
        if metadata[field.to_s].present?
          data[field] = metadata[field.to_s]
          metadata.delete(field.to_s)
        end
      end
      update_profile(entry["id"], data, metadata)
    end
  end

  private

  def update_profile(id, data, metadata)
      data = connection.quote(data.to_yaml)
      metadata = connection.quote(metadata.to_json)
      execute("UPDATE profiles SET data = #{data}, metadata = #{metadata}"\
              " WHERE id = #{id}")
  end
end
