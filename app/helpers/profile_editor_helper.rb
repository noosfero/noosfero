module ProfileEditorHelper

  NATIONALITY = [
    N_('Afghan'),
    N_('Albanian'),
    N_('Algerian'),
    N_('American'),
    N_('Andorran'),
    N_('Angolan'),
    N_('Antiguans'),
    N_('Argentinean'),
    N_('Armenian'),
    N_('Australian'),
    N_('Austrian'),
    N_('Azerbaijani'),
    N_('Bahamian'),
    N_('Bahraini'),
    N_('Bangladeshi'),
    N_('Barbadian'),
    N_('Barbudans'),
    N_('Batswana'),
    N_('Belarusian'),
    N_('Belgian'),
    N_('Belizean'),
    N_('Beninese'),
    N_('Bhutanese'),
    N_('Bolivian'),
    N_('Bosnian'),
    N_('Brazilian'),
    N_('British'),
    N_('Bruneian'),
    N_('Bulgarian'),
    N_('Burkinabe'),
    N_('Burmese'),
    N_('Burundian'),
    N_('Cambodian'),
    N_('Cameroonian'),
    N_('Canadian'),
    N_('Cape Verdean'),
    N_('Central African'),
    N_('Chadian'),
    N_('Chilean'),
    N_('Chinese'),
    N_('Colombian'),
    N_('Comoran'),
    N_('Congolese'),
    N_('Costa Rican'),
    N_('Croatian'),
    N_('Cuban'),
    N_('Cypriot'),
    N_('Czech'),
    N_('Danish'),
    N_('Djibouti'),
    N_('Dominican'),
    N_('Dutch'),
    N_('East Timorese'),
    N_('Ecuadorean'),
    N_('Egyptian'),
    N_('Emirian'),
    N_('Equatorial Guinean'),
    N_('Eritrean'),
    N_('Estonian'),
    N_('Ethiopian'),
    N_('Fijian'),
    N_('Filipino'),
    N_('Finnish'),
    N_('French'),
    N_('Gabonese'),
    N_('Gambian'),
    N_('Georgian'),
    N_('German'),
    N_('Ghanaian'),
    N_('Greek'),
    N_('Grenadian'),
    N_('Guatemalan'),
    N_('Guinea-Bissauan'),
    N_('Guinean'),
    N_('Guyanese'),
    N_('Haitian'),
    N_('Herzegovinian'),
    N_('Honduran'),
    N_('Hungarian'),
    N_('I-Kiribati'),
    N_('Icelander'),
    N_('Indian'),
    N_('Indonesian'),
    N_('Iranian'),
    N_('Iraqi'),
    N_('Irish'),
    N_('Israeli'),
    N_('Italian'),
    N_('Ivorian'),
    N_('Jamaican'),
    N_('Japanese'),
    N_('Jordanian'),
    N_('Kazakhstani'),
    N_('Kenyan'),
    N_('Kittian and Nevisian'),
    N_('Kuwaiti'),
    N_('Kyrgyz'),
    N_('Laotian'),
    N_('Latvian'),
    N_('Lebanese'),
    N_('Liberian'),
    N_('Libyan'),
    N_('Liechtensteiner'),
    N_('Lithuanian'),
    N_('Macedonian'),
    N_('Malagasy'),
    N_('Malawian'),
    N_('Malaysian'),
    N_('Maldivian'),
    N_('Malian'),
    N_('Maltese'),
    N_('Marshallese'),
    N_('Mauritanian'),
    N_('Mauritian'),
    N_('Mexican'),
    N_('Micronesian'),
    N_('Moldovan'),
    N_('Monacan'),
    N_('Mongolian'),
    N_('Moroccan'),
    N_('Mosotho'),
    N_('Motswana'),
    N_('Mozambican'),
    N_('Namibian'),
    N_('Nauruan'),
    N_('Nepalese'),
    N_('New Zealander'),
    N_('Ni-Vanuatu'),
    N_('Nicaraguan'),
    N_('Nigerian'),
    N_('Nigerien'),
    N_('North Korean'),
    N_('Northern Irish'),
    N_('Norwegian'),
    N_('Omani'),
    N_('Other'),
    N_('Pakistani'),
    N_('Palauan'),
    N_('Panamanian'),
    N_('Papua New Guinean'),
    N_('Paraguayan'),
    N_('Peruvian'),
    N_('Polish'),
    N_('Portuguese'),
    N_('Qatari'),
    N_('Romanian'),
    N_('Russian'),
    N_('Rwandan'),
    N_('Saint Lucian'),
    N_('Salvadoran'),
    N_('Samoan'),
    N_('San Marinese'),
    N_('Sao Tomean'),
    N_('Saudi'),
    N_('Scottish'),
    N_('Senegalese'),
    N_('Serbian'),
    N_('Seychellois'),
    N_('Sierra Leonean'),
    N_('Singaporean'),
    N_('Slovakian'),
    N_('Slovenian'),
    N_('Solomon Islander'),
    N_('Somali'),
    N_('South African'),
    N_('South Korean'),
    N_('Spanish'),
    N_('Sri Lankan'),
    N_('Sudanese'),
    N_('Surinamer'),
    N_('Swazi'),
    N_('Swedish'),
    N_('Swiss'),
    N_('Syrian'),
    N_('Taiwanese'),
    N_('Tajik'),
    N_('Tanzanian'),
    N_('Thai'),
    N_('Togolese'),
    N_('Tongan'),
    N_('Trinidadian or Tobagonian'),
    N_('Tunisian'),
    N_('Turkish'),
    N_('Tuvaluan'),
    N_('Ugandan'),
    N_('Ukrainian'),
    N_('Uruguayan'),
    N_('Uzbekistani'),
    N_('Venezuelan'),
    N_('Vietnamese'),
    N_('Welsh'),
    N_('Yemenite'),
    N_('Zambian'),
    N_('Zimbabwean')
  ]

  AREAS_OF_STUDY = [
    N_('Agrometeorology'),
    N_('Agronomy'),
    N_('Foods'),
    N_('Anthropology'),
    N_('Architecture'),
    N_('Arts'),
    N_('Astronomy'),
    N_('Librarianship'),
    N_('Biosciences'),
    N_('Biophysics'),
    N_('Biology'),
    N_('Biotechnology'),
    N_('Botany'),
    N_('Science Politics'),
    N_('Accounting and Actuarial Science'),
    N_('Morphologic Sciences'),
    N_('Computer Science'),
    N_('Rural Development'),
    N_('Law'),
    N_('Ecology'),
    N_('Economy'),
    N_('Education'),
    N_('Long-distance Education'),
    N_('Physical Education'),
    N_('Professional Education'),
    N_('Nursing'),
    N_('Engineerings'),
    N_('Basic and Average education'),
    N_('Statistics'),
    N_('Stratigraphy'),
    N_('Pharmacy'),
    N_('Pharmacology'),
    N_('Philosophy'),
    N_('Physics'),
    N_('Plant Protection'),
    N_('Genetics'),
    N_('Geosciences'),
    N_('Geography'),
    N_('Geology'),
    N_('Hydrology'),
    N_('Hydromechanics'),
    N_('History'),
    N_('Horticulture'),
    N_('Informatics'),
    N_('Interdisciplinary'),
    N_('Journalism'),
    N_('Letters'),
    N_('Languages'),
    N_('Mathematics'),
    N_('Medicines'),
    N_('Medicine'),
    N_('Metallurgy'),
    N_('Microbiology'),
    N_('Mineralogy'),
    N_('Music'),
    N_('Nutrition'),
    N_('Odontology'),
    N_('Paleontology'),
    N_('Petrology'),
    N_('Production'),
    N_('Psychology'),
    N_('Psychiatry'),
    N_('Quality'),
    N_('Chemistry'),
    N_('Health'),
    N_('Remote Sensing'),
    N_('Forestry'),
    N_('Sociology'),
    N_('Ground'),
    N_('Theater'),
    N_('Transport'),
    N_('Urbanism'),
    N_('Veterinary Medicine'),
    N_('Zoology'),
    N_('Zootecnia'),
    N_('Others')
  ]

  SCHOOLING = [
    N_('Post-Doctoral'),
    N_('Ph.D.'),
    N_('Masters'),
    N_('Graduate'),
    N_('High School'),
    N_('Elementary School')
  ]

  SCHOOLING_STATUS = [
    N_('Concluded'),
    N_('Incomplete'),
    N_('Ongoing')
  ]

  def select_area(title, object, method, options)
    labelled_form_field(title, select(object, method, [[_('[Select ...]'), nil]] + ProfileEditorHelper::AREAS_OF_STUDY.map{|s| [gettext(s), s]}, {}, options))
  end

  def country_helper
    @country_helper ||= CountriesHelper::Object.instance
  end

  def select_profile_country(object_name, profile, html_options = {}, options = {})
    options[:selected] = profile.metadata['country']
    select(object_name, :country, [[_('Select a country...'), nil]] + country_helper.countries, options, html_options)
  end

  def select_profile_state(object_name, profile, html_options = {}, options = {})
    states = NationalRegion.states.order(:name)
                                  .pluck(:name, :national_region_code)

    if profile.state.present? &&
       !states.find { |c| c[1] == profile.metadata['state'] }
      states.unshift [profile.state, profile.state]
    end
    options[:selected] = profile.metadata['state']
    select(object_name, :state, [[_('Select a state...'), nil]] + states, options, html_options)
  end

  def select_profile_city(object_name, profile, html_options = {}, options = {})
    cities = NationalRegion.cities.order(:name)
                                  .pluck(:name, :national_region_code)

    if profile.city.present? &&
       !cities.find { |c| c[1] == profile.metadata['city'] }
      cities.unshift [profile.city, profile.city]
    end
    options[:selected] = profile.metadata['city']
    select(object_name, :city, [[_('Select a city...'), nil]] + cities, options, html_options)
  end

  def select_schooling(object, method, options)
    select(object, method, [[_('[Select ...]'), nil]] + ProfileEditorHelper::SCHOOLING.map{|s| [gettext(s), s]}, {}, options)
  end

  def select_schooling_status(object, method, options)
    select(object, method, [[_('[Select ...]'), nil]] + ProfileEditorHelper::SCHOOLING_STATUS.map{|s| [gettext(s), s]}, {}, options)
  end

  def select_nationality(object, method, options)
    select(object, method, [[_('[Select ...]'), nil]] + ProfileEditorHelper::NATIONALITY.map{|s| [gettext(s), s]}, {}, options)
  end

  def select_preferred_domain(object)
    profile = instance_variable_get("@#{object}")
    domains = []
    if profile
      if profile.preferred_domain
        # FIXME should be able to change
        return ''
      else
        domains = profile.possible_domains
      end
    else
      domains = environment.domains
    end
    select_domain_prompt = '&lt;'.html_safe + _('Select domain').html_safe + '&gt;'.html_safe
    select_field = select(object, :preferred_domain_id, domains.map {
      |item| [item.name, item.id]}, :prompt => select_domain_prompt.html_safe)

    labelled_form_field(_('Preferred domain name:'), select_field)
  end

  def control_panel(&block)
    concat(
      content_tag(
        'div',
        capture(&block) + tag('br', :style => 'clear: left'),
        :class => 'control-panel')
    )
  end

  def control_panel_button(entry, profile)
    klass = [entry.options[:class], "entry"].compact.join(' ')
    link_to font_awesome(entry.icon, entry.name), entry.url(profile), entry.options.merge(id: "#{entry.identifier}-entry", class:  klass, 'data-keywords' => entry.keywords.join(' '))
  end

  def unchangeable_privacy_field(profile)
    labelled_check_box(_('Public'), '', '', true, :disabled => true, :title => _('This field must be public'), :class => 'disabled')
  end

  def select_editor(title, object, method, options)
    labelled_form_field(title, select(object, method, current_person.available_editors.map { |k,v| [v, k] }))
  end

end
