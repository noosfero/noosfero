Then /^the response should be valid for (.+) minutes$/ do |n|
  response.headers['Cache-Control'].split(/,\s*/).should include("max-age=#{n.to_i * 60}")
end

Then /^the cache should be public/ do
  response.headers['Cache-Control'].split(/,\s*/).should include("public")
end

Then /^there must be no cache at all$/ do
  parts = response.headers['Cache-Control'].split(/,\s*/)
  parts.should include('must-revalidate')
  parts.should include('max-age=0')
end

Then 'there must be no cookies' do
  cookies.should == {}
end

Then /^there must be a cookie "(.+)"$/ do |cookie_name|
  cookies.keys.should include(cookie_name)
end
