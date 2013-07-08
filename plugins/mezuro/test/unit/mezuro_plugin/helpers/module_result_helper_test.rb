require "test_helper"

class ModuleResultHelperTest < ActiveSupport::TestCase

  should 'return last module name when receive a string' do
    name = 'Class'
    assert_equal name, MezuroPlugin::Helpers::ModuleResultHelper.module_name(name)
  end

  should 'return last module name when receive an array of strings' do
    name = ['Class', 'Module']
    assert_equal name.last, MezuroPlugin::Helpers::ModuleResultHelper.module_name(name)
  end

end
