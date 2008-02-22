module Noosfero::Test

  def get(path, parameters = nil, headers = nil)
    super(path, (parameters ? self.class.extra_parameters.merge(parameters) : self.class.extra_parameters) , headers)
  end

  def post(path, parameters = nil, headers = nil)
    super(path, (parameters ? self.class.extra_parameters.merge(parameters) : self.class.extra_parameters), headers)
  end

  module ClassMethods
    def noosfero_test(parameters)
      instance_variable_set('@noosfero_test_extra_parameters', parameters)
      def extra_parameters
        @noosfero_test_extra_parameters
      end
      include Noosfero::Test
    end
  end

end

Test::Unit::TestCase.send(:extend, Noosfero::Test::ClassMethods)
