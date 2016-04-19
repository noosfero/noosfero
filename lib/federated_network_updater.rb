module FederatedNetworkUpdater
  require 'json'
  require 'net/http'
  require './app/models/federated_network'

  def self.import_json
    source = 'http://directory.noosfero.org/all.json'
    begin
      resp = Net::HTTP.get_response(URI.parse(source))
    rescue Exception => ex
      Rails.logger.error "Import Federated Networks Error: #{ex}"
    end
    JSON.parse(resp.body)
  end

  def self.process_data
    data = import_json

    if data.key?('sites')
      data['sites'].each do |site|
        if site.key?('name') && site.key?('url') && site.key?('id')
          federated_network = FederatedNetwork.find_or_create_by(identifier: site['id'])
          federated_network.update(name: site['name'],
                                   url: site['url'],
                                   screenshot: site['screnshot'],
                                   thumbnail: site['thumbnail'])
        else
          Rails.logger.error 'Federated network JSON has site without name or url'
        end
      end
    else
      Rails.logger.error 'Federated network JSON has no sites key'
    end
  end
end
