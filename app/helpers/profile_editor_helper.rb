module ProfileEditorHelper


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
    N_('Undergraduate'),
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

  def select_country(title, object, method, html_options = {}, options = {})
    labelled_form_field(title, select(object, method, [[_('[Select ...]'), nil]] + country_helper.countries, options, html_options))
  end

  def select_schooling(object, method, options)
    select(object, method, [[_('[Select ...]'), nil]] + ProfileEditorHelper::SCHOOLING.map{|s| [gettext(s), s]}, {}, options)
  end

  def select_schooling_status(object, method, options)
    select(object, method, [[_('[Select ...]'), nil]] + ProfileEditorHelper::SCHOOLING_STATUS.map{|s| [gettext(s), s]}, {}, options)
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
    labelled_form_field(_('Preferred domain name:'), select(object, :preferred_domain_id, domains.map {|item| [item.name, item.id]}, :prompt => '&lt;' + _('Select domain') + '&gt;'))
  end

  def control_panel(&block)
    concat(
      content_tag(
        'div',
        capture(&block) + tag('br', :style => 'clear: left'),
        :class => 'control-panel')
    )
  end

  def control_panel_button(title, icon, url, html_options = {})
    html_options ||= {}
    link_to title, url, html_options.merge(:class => 'control-panel-%s' % icon)
  end

  def unchangeable_privacy_field(profile)
    if profile.public?
      labelled_check_box(_('Public'), '', '', true, :disabled => true, :title => _('This field must be public'), :class => 'disabled')
    else
      ''
    end
  end

end
