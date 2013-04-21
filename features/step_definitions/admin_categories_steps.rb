When /^I follow "([^"]*)" and wait while it hides$/ do |link|
  click_link link
  wait_until{ page.should have_no_css('a', :text => link, :visible => true) }
end
