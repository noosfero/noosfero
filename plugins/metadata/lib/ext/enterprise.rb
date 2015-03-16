require_dependency 'enterprise'
require_dependency "#{File.dirname __FILE__}/profile"

class Enterprise

  metadata_spec namespace: :og, tags: {
    type: proc{ |e, plugin| plugin.context.params[:og_type] || MetadataPlugin.og_types[:enterprise] || :enterprise },
  }

  # required for businness
  metadata_spec namespace: 'place:location', tags: {
    latitude: proc{ |e, plugin| if e.lat.present? then e.lat else e.environment.lat end },
    longitude: proc{ |e, plugin| if e.lng.present? then e.lng else e.environment.lng end },
  }

  metadata_spec namespace: 'business:contact_data', tags: {
    # all required
    email: proc{ |e, plugin| if e.contact_email.present? then e.contact_email else e.environment.contact_email end },
    phone_number: proc{ |e, plugin| if e.contact_phone.present? then e.contact_phone else e.environment.contact_phone end },
    street_address: proc{ |e, plugin| if e.address.present? then e.address else e.environment.address end },
    locality: proc{ |e, plugin| if e.city.present? then e.city else e.environment.city end },
    region: proc{ |e, plugin| if e.state.present? then e.state else e.environment.state end },
    postal_code: proc{ |e, plugin| if e.zip_code.present? then e.zip_code else e.environment.postal_code end },
    country_name: proc{ |e, plugin| if e.country.present? then e.country else e.environment.country_name end },
  }

end
