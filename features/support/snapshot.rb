
After do |scenario|
  if scenario.failed?
    if ENV['TRAVIS']
      build = ENV['TRAVIS_BUILD_NUMBER']
      page.driver.save_screenshot "./tmp/artifact-travis-#{build}-#{scenario.name.parameterize}.png"
    end
  end
end
