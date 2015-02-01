require_dependency 'enterprise'
require_dependency "#{File.dirname __FILE__}/profile"

class Enterprise

  metadata_spec namespace: :og, tags: {
    type: MetadataPlugin.og_types[:enterprise] || :enterprise,
  }

  metadata_spec namespace: 'business:contact_data', tags: {
    email: proc{ |e, plugin| e.contact_email },
	  phone_number: proc{ |e, plugin| e.contact_phone },
	  street_address: proc{ |e, plugin| e.address },
	  locality: proc{ |e, plugin| e.city },
	  region: proc{ |e, plugin| e.state },
	  postal_code: proc{ |e, plugin| e.zip_code },
	  country_name: proc{ |e, plugin| e.country },
  }

end
