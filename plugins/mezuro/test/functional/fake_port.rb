class FakePort < Kalibro::Client::Port

  def initialize(endpoint)
    super(endpoint)
    self.service_address = 'http://localhost:8080/KalibroFake/'
  end
end
