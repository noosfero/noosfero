require_dependency 'enterprise'
require_dependency "#{File.dirname __FILE__}/profile"

class Enterprise

  Metadata = Metadata.merge({
    'og:type' => MetadataPlugin.og_types[:enterprise],
	  'business:contact_data:email' => proc{ |e, c| e.contact_email },
	  'business:contact_data:phone_number' => proc{ |e, c| e.contact_phone },
	  'business:contact_data:street_address' => proc{ |e, c| e.address },
	  'business:contact_data:locality' => proc{ |e, c| e.city },
	  'business:contact_data:region' => proc{ |e, c| e.state },
	  'business:contact_data:postal_code' => proc{ |e, c| e.zip_code },
	  'business:contact_data:country_name' => proc{ |e| e.country },
	  'place:location:latitude' => proc{ |e, c| p.lat },
	  'place:location:longitude' => proc{ |e, c| p.lng },
  })
end
