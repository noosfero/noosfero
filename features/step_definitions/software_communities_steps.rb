Given /^SoftwareInfo has initial default values on database$/ do
  LicenseInfo.create(:version=>"None", :link=>"")
  LicenseInfo.create(:version=>"GPL-2", :link =>"www.gpl2.com")
  LicenseInfo.create(:version=>"GPL-3", :link =>"www.gpl3.com")

  ProgrammingLanguage.create(:name=>"C")
  ProgrammingLanguage.create(:name=>"C++")
  ProgrammingLanguage.create(:name=>"Ruby")
  ProgrammingLanguage.create(:name=>"Python")

  DatabaseDescription.create(:name => "Oracle")
  DatabaseDescription.create(:name => "MySQL")
  DatabaseDescription.create(:name => "Apache")
  DatabaseDescription.create(:name => "PostgreSQL")

  OperatingSystemName.create(:name=>"Debian")
  OperatingSystemName.create(:name=>"Fedora")
  OperatingSystemName.create(:name=>"CentOS")
end

Given /^I type in "([^"]*)" in autocomplete list "([^"]*)" and I choose "([^"]*)"$/ do |typed, input_field_selector, should_select|
  # Wait the page javascript load
  sleep 1
  # Basicaly it, search for the input field, type something, wait for ajax end select an item
  page.driver.browser.execute_script %Q{
    var search_query = "#{input_field_selector}.ui-autocomplete-input";
    var input = jQuery(search_query).first();

    input.trigger('click');
    input.val('#{typed}');
    input.trigger('keydown');

    window.setTimeout(function(){
      search_query = ".ui-menu-item a:contains('#{should_select}')";
      var typed = jQuery(search_query).first();

      typed.trigger('mouseenter').trigger('click');
      console.log(jQuery('#license_info_id'));
    }, 1000);
  }
  sleep 1
end

Given /^Institutions has initial default values on database$/ do
  GovernmentalPower.create(:name => "Executivo")
  GovernmentalPower.create(:name => "Legislativo")
  GovernmentalPower.create(:name => "Judiciario")

  GovernmentalSphere.create(:name => "Federal")

  JuridicalNature.create(:name => "Autarquia")
  JuridicalNature.create(:name => "Administracao Direta")
  JuridicalNature.create(:name => "Empresa Publica")
  JuridicalNature.create(:name => "Fundacao")
  JuridicalNature.create(:name => "Orgao Autonomo")
  JuridicalNature.create(:name => "Sociedade")
  JuridicalNature.create(:name => "Sociedade Civil")
  JuridicalNature.create(:name => "Sociedade de Economia Mista")

  national_region = NationalRegion.new
  national_region.name = "Distrito Federal"
  national_region.national_region_code = '35'
  national_region.national_region_type_id = NationalRegionType::STATE
  national_region.save
end

Given /^the following organization ratings$/ do |table|
  table.hashes.each do |item|
    person = User.where(login: item[:user_login]).first.person
    organization = Organization.where(name: item[:organization_name]).first

    rating = OrganizationRating.new
    rating.value = item[:value]
    rating.organization_id = organization.id
    rating.person_id = person.id
    rating.saved_value = item[:saved_value]
    rating.institution_id = Institution.where(name: item[:institution_name]).first.id
    rating.save

    comment_task = CreateOrganizationRatingComment.create!(
      :body => "empty comment",
      :requestor => person,
      :organization_rating_id => rating.id,
      :target => organization)

    comment_task.status = item[:task_status]
    comment_task.save
  end
end

Given /^the following public institutions?$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |item|
    community = Community.new
    community.name = item[:name]
    community.country = item[:country]
    community.state = item[:state]
    community.city = item[:city]
    community.save!

    governmental_power = GovernmentalPower.where(:name => item[:governmental_power]).first
    governmental_sphere = GovernmentalSphere.where(:name => item[:governmental_sphere]).first

    juridical_nature = JuridicalNature.create(:name => item[:juridical_nature])

    institution = PublicInstitution.new(:name => item[:name], :type => "PublicInstitution", :acronym => item[:acronym], :cnpj => item[:cnpj], :juridical_nature => juridical_nature, :governmental_power => governmental_power, :governmental_sphere => governmental_sphere)
    institution.community = community
    institution.corporate_name = item[:corporate_name]
    institution.save!
  end
end

Given /^the following software language$/ do |table|
  table.hashes.each do |item|
    programming_language = ProgrammingLanguage.where(:name=>item[:programing_language]).first
    software_language = SoftwareLanguage::new

    software_language.programming_language = programming_language
    software_language.version = item[:version]
    software_language.operating_system = item[:operating_system]

    software_language.save!
  end
end

Given /^the following software databases$/ do |table|
  table.hashes.each do |item|
    database_description = DatabaseDescription.where(:name=>item[:database_name]).first
    software_database = SoftwareDatabase::new

    software_database.database_description = database_description
    software_database.version = item[:version]
    software_database.operating_system = item[:operating_system]

    software_database.save!
  end
end


Given /^the following operating systems$/ do |table|
  table.hashes.each do |item|
    operating_system_name = OperatingSystemName.where(:name=>item[:operating_system_name]).first
    operating_system = OperatingSystem::new

    operating_system.operating_system_name = operating_system_name
    operating_system.version = item[:version]

    operating_system.save!
  end
end

Given /^the following softwares$/ do |table|
  table.hashes.each do |item|
    software_info = SoftwareInfo.new
    community = Community.create(:name=>item[:name])
    software_info.community = community

    software_info.finality = item[:finality] if item[:finality]
    software_info.acronym = item[:acronym] if item[:acronym]
    software_info.finality = item[:finality] if item[:finality]
    software_info.finality ||= "something"
    software_info.operating_platform = item[:operating_platform] if item[:operating_platform]
    software_info.objectives = item[:objectives] if item[:objectives]
    software_info.features = item[:features] if item[:features]
    software_info.public_software = item[:public_software] == "true" if item[:public_software]
    software_info.license_info = LicenseInfo.create :version=>"GPL - 1.0"

    if item[:software_language]
      programming_language = ProgrammingLanguage.where(:name=>item[:software_language]).first
      software_language = SoftwareLanguage.where(:programming_language_id=>programming_language).first
      software_info.software_languages << software_language
    end

    if item[:software_database]
      database_description = DatabaseDescription.where(:name=>item[:software_database]).first
      software_database = SoftwareDatabase.where(:database_description_id=>database_description).first
      software_info.software_databases << software_database
    end

    if item[:operating_system]
      operating_system_name = OperatingSystemName.where(:name => item[:operating_system]).first
      operating_system = OperatingSystem.where(:operating_system_name_id => operating_system_name).first
      software_info.operating_systems << operating_system
    end

    if item[:categories]
      categories = item[:categories].split(",")
      categories.map! {|category| category.strip}

      categories.each do |category_name|
        category = Category.find_by_name category_name
        community.categories << category
      end
    end

    if item[:owner]
      owner = item[:owner]
      community.add_admin Profile[owner]
    end

    software_info.save!
  end
end

# Dynamic table steps
Given /^I fill in first "([^"]*)" class with "([^"]*)"$/ do |selector, value|
  evaluate_script "jQuery('#{selector}').first().attr('value', '#{value}') && true"
end

Given /^I fill in last "([^"]*)" class with "([^"]*)"$/ do |selector, value|
  evaluate_script "jQuery('#{selector}').last().attr('value', '#{value}') && true"
end

Given /^I click on the first button with class "([^"]*)"$/ do |selector|
  evaluate_script "jQuery('#{selector}').first().trigger('click') && true"
end

Given /^I click on the last button with class "([^"]*)"$/ do |selector|
  evaluate_script "jQuery('#{selector}').last().trigger('click') && true"
end

Given /^I click on anything with selector "([^"]*)"$/ do |selector|
  page.evaluate_script("jQuery('##{selector}').click();")
end

Given /^I should see "([^"]*)" of this selector "([^"]*)"$/ do |quantity, selector|
  evaluate_script "jQuery('#{selector}').length == '#{quantity}'"
end

Given /^selector "([^"]*)" should have any "([^"]*)"$/ do |selector, text|
  evaluate_script "jQuery('#{selector}').html().indexOf('#{text}') != -1"
end

Given /^I click on table number "([^"]*)" selector "([^"]*)" and select the value "([^"]*)"$/ do |number, selector, value|
  evaluate_script "jQuery('#{selector}:nth-child(#{number}) select option:contains(\"#{value}\")').selected() && true"
end

Given /^I fill with "([^"]*)" in field with name "([^"]*)" of table number "([^"]*)" with class "([^"]*)"$/ do |value, name, number, selector|
  evaluate_script "jQuery('#{selector}:nth-child(#{number}) input[name=\"#{name}\"]').val('#{value}') && true"
end

Given /^I sleep for (\d+) seconds$/ do |time|
  sleep time.to_i
end

Given /^I am logged in as mpog_admin$/ do
  visit('/account/logout')

  user = User.new(:login => 'admin_user', :password => '123456', :password_confirmation => '123456', :email => 'admin_user@example.com')
  person = Person.new :name=>"Mpog Admin", :identifier=>"mpog-admin"
  user.person = person
  user.save!

  user.activate
  e = Environment.default
  e.add_admin(user.person)

  visit('/account/login')
  fill_in("Username", :with => user.login)
  fill_in("Password", :with => '123456')
  click_button("Log in")
end

Given /^I should see "([^"]*)" before "([^"]*)"$/ do |before, after|
  assert page.body.index("#{before}") < page.body.index("#{after}")
end

Given /^I keyup on selector "([^"]*)"$/ do |selector|
  selector_founded = evaluate_script("jQuery('#{selector}').trigger('keyup').length != 0")
  selector_founded.should be_true
end

Then /^there should be (\d+) divs? with class "([^"]*)"$/ do |count, klass|
  should have_selector("div.#{klass}", :count => count)
end

Then /^I should see "([^"]*)" in "([^"]*)" field$/ do |content, field|
  should have_field(field, :with => content)
end

Given /^I should see "([^"]*)" in the page/ do |message|
  assert_match message, page.body
end
